type HttpMethods = 'GET' | 'POST' | 'PATCH' | 'PUT' | 'DELETE'
type BaseResource = {
  path: (args: any) => string
  names: string[]
  Methods?: any
  Params?: { [method in HttpMethods]?: any }
  Return?: { [method in HttpMethods]?: any }
}
async function f<
  Method extends Exclude<Resource['Methods'], undefined>,
  Resource extends BaseResource,
  Params extends Exclude<Resource['Params'], undefined>[Method],
  Return extends Exclude<Exclude<Resource['Return'], undefined>[Method], void>
>(method: Method, { path, names }: Resource, params: Params): Promise<Return> {
  const paramsNotInNames = Object.keys(params).reduce<object>((ps, key) => names.indexOf(key) === - 1 ? { ...ps, [key]: params[key] } : ps, {})
  const response = await fetch(path(params), {
    method,
    headers: {
      'Content-Type': 'application/json'
    }
  })
  return response.json() as Promise<Return>
}
