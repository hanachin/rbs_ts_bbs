require 'rbs'

unless RBS::Types.constants.sort == [:NoSubst, :EmptyEachType, :Literal, :Bases, :Interface, :Tuple, :Union, :ClassSingleton, :Application, :ClassInstance, :Record, :Function, :Optional, :Variable, :Alias, :Proc, :Intersection, :NoFreeVariables].sort
  raise 'Unsupported'
end

unless RBS::Types::Bases.constants.sort == [:Instance, :Base, :Class, :Void, :Any, :Nil, :Top, :Bottom, :Self, :Bool].sort
  raise 'Unsupported'
end

using Module.new {
  using self

  refine(Object) do
    def parse_type_name(string)
      RBS::Namespace.parse(string).yield_self do |namespace|
        last = namespace.path.last
        RBS::TypeName.new(name: last, namespace: namespace.parent)
      end
    end

    def typescript_type_name(controller, action)
      "#{controller.to_s.camelcase(:lower)}#{action.to_s.camelcase}Params"
    end

    def typescript_path_function(route_info, verb_type)
      name = route_info.fetch(:name).camelize(:lower)
      parts = route_info.fetch(:parts)
      body = TypeScriptVisitor::INSTANCE.accept(route_info.fetch(:spec), '')
      <<~TS
      export const #{name} = {
        path: (#{ parts.empty? ? '' : "{ #{parts.join(', ')} }: any" }) => #{ body },
        names: [#{ parts.map { |n| n.to_json + " as const" }.join(",") }]
      } as {
        Methods?: {
      #{verb_type.map { |v, t| "    #{v}: #{t}" }.join(",\n")}
        }
      }
      TS
    end

    def routes_info
      rs = Rails.application.routes.routes.filter_map { |r|
        {
          verb: r.verb,
          name: r.name,
          parts: r.parts,
          reqs: r.requirements,
          spec: r.path.spec
        } if !r.internal && !r.app.engine?
      }
      rs.inject([]) do |new_rs, r|
        prev_r = new_rs.last
        if prev_r && r[:name].nil? && r.fetch(:spec).to_s != prev_r.fetch(:spec).to_s
          # puts prev_r[:name]
          # puts r.fetch(:spec).to_s
          # puts prev_r.fetch(:spec).to_s
          # raise
          next new_rs
        end
        r[:name] = prev_r[:name] if prev_r && r[:name].nil?
        next new_rs if r[:name].nil?
        new_rs << r
      end
    end

    def collect_action_interfaces
      loader = RBS::EnvironmentLoader.new
      dir = Pathname('sig')
      loader.add(path: dir)
      env = RBS::Environment.new
      loader.load(env: env)
      builder = RBS::DefinitionBuilder.new(env: env)
      interfaces = {}
      ApplicationController.subclasses.each do |subclass|
        subclass_type_name = parse_type_name(subclass.inspect).absolute!
        definition = builder.build_instance(subclass_type_name)
        actions = subclass.public_instance_methods(false)
        actions.each do |action|
          method = definition.methods[action]
          next unless method
          raise 'Unsupported' unless method.method_types.size == 1
          method_type = method.method_types.first
          raise 'Unsupported' unless method_type.is_a?(RBS::MethodType)
          interface = method_type.to_s
          controller = subclass.to_s.sub(/Controller$/, '').underscore.to_s
          interfaces[controller] ||= {}
          interfaces[controller][action.to_s] = interface.empty? ? '{}' : interface
        rescue
          $stderr.puts $!.backtrace.join("\n")
          $stderr.puts "#{subclass}##{action} not supported"
        end
      end
      interfaces
    end
  end

  refine(RBS::MethodType) do
    def to_s
      raise 'Unsupported' unless type_params.empty?

      s = case
          when block && block.required
            raise 'Unsupported'
          when block
            raise 'Unsupported'
          else
            type.param_to_s
          end

      if type_params.empty?
        s
      else
        raise 'Unsuported'
      end
    end
  end

  refine(RBS::Types::Function::Param) do
    def to_s
      type.to_s
    end
  end

  refine(RBS::Types::Function) do
    def param_to_s
      params = []
      params.push(*required_positionals.map { |param| "#{param.name}: #{param.type}" })
      params.push(*optional_positionals.map {|param| "#{param.name}?: #{param.type}" })
      raise 'Unsupported' if rest_positionals
      params.push(*trailing_positionals.map { |param| "#{param.name}: #{param.type}" })
      params.push(*required_keywords.map {|name, param| "#{name}: #{param}" })
      params.push(*optional_keywords.map {|name, param| "#{name}?: #{param}" })
      raise 'Unsupported' if rest_keywords

      return '' if params.empty?

      "{ #{params.join("; ")} }"
    end

    def return_to_s
      raise 'Unsupported'
    end
  end

  # RBS::Types.constants.map { RBS::Types.const_get(_1) }.select { _1.public_instance_methods(false).include?(:to_s) }
  refine(RBS::Types::Literal) do
    def to_s(level = 0)
      case literal
      when Symbol, String
        literal.to_s.inspect
      when Integer, TrueClass, FalseClass
        literal.inspect
      else
        raise 'Unsupported'
      end
    end
  end

  refine(RBS::Types::Interface) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Tuple) do
    # copy from super to use refinements
    def to_s(level = 0)
      if types.empty?
        "[ ]"
      else
        "[ #{types.map(&:to_s).join(", ")} ]"
      end
    end
  end

  refine(RBS::Types::Record) do
    def to_s(level = 0)
      return "{ }" if self.fields.empty?

      fields = self.fields.map do |key, type|
        if key.is_a?(Symbol) && key.match?(/\A[A-Za-z_][A-Za-z0-9_]*\z/) && !key.match?(RBS::Parser::KEYWORDS_RE)
          "#{key.to_s}: #{type}"
        else
          "#{key.to_s.inspect}: #{type}"
        end
      end
      "{ #{fields.join("; ")} }"
    end
  end

  refine(RBS::Types::Union) do
    # copy from super to use refinements
    def to_s(level = 0)
      if level > 0
        "(#{types.map(&:to_s).join(" | ")})"
      else
        types.map(&:to_s).join(" | ")
      end
    end
  end

  refine(RBS::Types::ClassSingleton) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Application) do
    def to_s(level = 0)
      case name.to_s
      when '::Integer'
        'number'
      when '::String'
        'string'
      else
        raise 'Unsupported'
      end
    end
  end

  refine(RBS::Types::Optional) do
    # copy from super to use refinements
    def to_s(level = 0)
      if type.is_a?(RBS::Types::Literal) && type.literal.is_a?(Symbol)
        "#{type.to_s(1)} ?"
      else
        "#{type.to_s(1)}?"
      end
    end
  end

  refine(RBS::Types::Variable) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Alias) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Proc) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Intersection) do
    # copy from super to use refinements
    def to_s(level = 0)
      strs = types.map {|ty| ty.to_s(2) }
      if level > 0
        "(#{strs.join(" & ")})"
      else
        strs.join(" & ")
      end
    end
  end

  # RBS::Types::Bases.constants.map { RBS::Types::Bases.const_get(_1) }
  refine(RBS::Types::Bases::Instance) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Bases::Base) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Bases::Class) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Bases::Void) do
    def to_s(level = 0)
      'void'
    end
  end

  refine(RBS::Types::Bases::Any) do
    def to_s(level = 0)
      'any'
    end
  end

  refine(RBS::Types::Bases::Nil) do
    def to_s(level = 0)
      'null'
    end
  end

  refine(RBS::Types::Bases::Top) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Bases::Bottom) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Bases::Self) do
    def to_s(level = 0)
      raise 'Unsupported'
    end
  end

  refine(RBS::Types::Bases::Bool) do
    def to_s(level = 0)
      'boolean'
    end
  end
}

class TypeScriptVisitor < ActionDispatch::Journey::Visitors::FunctionalVisitor
  private

  def binary(node, seed)
    visit(node.right, visit(node.left, seed) + ' + ')
  end

  def nary(node, seed)
    last_child = node.children.last
    node.children.inject(seed) { |s, c|
      string = visit(c, s)
      string << '|' unless last_child == c
      string
    }
  end

  def terminal(node, seed)
    seed + node.left.to_s.to_json
  end

  def visit_GROUP(node, seed)
    # TODO: support nested level 2
    # TODO: 
    # return node.left.left.class
    visit(node.left, seed.dup << '(() => { try { return ') << ' } catch { return "" } })()'
  end

  def visit_SYMBOL(n, seed);  variable(n, seed); end

  def variable(node, seed)
    if node.left.to_s[0] == '*'
      seed + '(' + node.left.to_s[1..-1] + ' ?? "")'
    else
      v = node.left.to_s[1..-1]
      seed + "(() => { if (#{v}) return #{v}; throw #{v.to_json} })()"
    end
  end

  INSTANCE = new
end

namespace :ts do
  task generate_params_interface: :environment do
    Rails.application.eager_load!

    interfaces = collect_action_interfaces
    interfaces.each do |controller, actions|
      actions.each do |action, interface|
        puts "type #{typescript_type_name(controller, action)} = #{interface}"
      end
    end
    routes_info.group_by { |r| r.fetch(:name) }.each do |name, routes|
      route = routes.first
      verb_type = routes.each_with_object({}) do |r, vt|
        controller = r.dig(:reqs, :controller)
        action = r.dig(:reqs, :action)
        next unless interfaces.dig(controller, action)
        vt[r.fetch(:verb)] = typescript_type_name(controller, action)
      end
      next if verb_type.empty?
      puts typescript_path_function(route, verb_type)
    end
    puts <<~TS
      type HttpMethods = 'GET' | 'POST' | 'PATCH' | 'DELETE'
      type BaseResource = {
        path?: (args: any) => string
        names?: string[]
        Methods?: { [method in HttpMethods]?: any }
      }
      function f<
        Method extends keyof Exclude<Resource['Methods'], undefined>,
        Resource extends BaseResource,
        Params extends Exclude<Resource['Methods'], undefined>[Method]
      >(method: Method, { path, names }: Resource, params: Params): string {
        if (typeof names === 'undefined' || typeof path === 'undefined') {
            throw 'error'
        }
        const paramsNotInNames = Object.keys(params).reduce<object>((ps, key) => names.indexOf(key) === - 1 ?  { ...ps, [key]: params[key] } : ps, {})
        return method + path(params) + JSON.stringify(paramsNotInNames)
      }
    TS
  end
end
