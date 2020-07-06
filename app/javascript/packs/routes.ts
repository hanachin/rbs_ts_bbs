type BoardsDestroyParams = { id: number }
type BoardsNewParams = {}
type BoardsUpdateParams = { id: number; title: string }
type BoardsShowParams = { id: number }
type BoardsIndexParams = {}
type BoardsEditParams = { id: number }
type BoardsCreateParams = { title: string }
type BoardsDestroyReturn = Exclude<{ url: string; message: string } | void, void>
type BoardsNewReturn = Exclude<void, void>
type BoardsUpdateReturn = Exclude<{ url: string; message: string } | string[] | void, void>
type BoardsShowReturn = Exclude<void, void>
type BoardsIndexReturn = Exclude<{ id: number; title: string }[] | void, void>
type BoardsEditReturn = Exclude<void, void>
type BoardsCreateReturn = Exclude<{ url: string; message: string } | string[] | void, void>
export const boards = {
  path: ({ format }: any) => "/" + "boards" + (() => { try { return "." + (() => { if (format) return format; throw "format" })() } catch { return "" } })(),
  names: ["format"]
} as {
  path: (args: any) => string
  names: ["format"]
  Methods?: "GET" | "POST"
  Params?: {
    GET: BoardsIndexParams,
    POST: BoardsCreateParams
  }
  Return?: {
    GET: BoardsIndexReturn,
    POST: BoardsCreateReturn
  }
}
export const newBoard = {
  path: ({ format }: any) => "/" + "boards" + "/" + "new" + (() => { try { return "." + (() => { if (format) return format; throw "format" })() } catch { return "" } })(),
  names: ["format"]
} as {
  path: (args: any) => string
  names: ["format"]
  Methods?: "GET"
  Params?: {
    GET: BoardsNewParams
  }
  Return?: {
    GET: BoardsNewReturn
  }
}
export const editBoard = {
  path: ({ id, format }: any) => "/" + "boards" + "/" + (() => { if (id) return id; throw "id" })() + "/" + "edit" + (() => { try { return "." + (() => { if (format) return format; throw "format" })() } catch { return "" } })(),
  names: ["id","format"]
} as {
  path: (args: any) => string
  names: ["id","format"]
  Methods?: "GET"
  Params?: {
    GET: BoardsEditParams
  }
  Return?: {
    GET: BoardsEditReturn
  }
}
export const board = {
  path: ({ id, format }: any) => "/" + "boards" + "/" + (() => { if (id) return id; throw "id" })() + (() => { try { return "." + (() => { if (format) return format; throw "format" })() } catch { return "" } })(),
  names: ["id","format"]
} as {
  path: (args: any) => string
  names: ["id","format"]
  Methods?: "GET" | "PATCH" | "PUT" | "DELETE"
  Params?: {
    GET: BoardsShowParams,
    PATCH: BoardsUpdateParams,
    PUT: BoardsUpdateParams,
    DELETE: BoardsDestroyParams
  }
  Return?: {
    GET: BoardsShowReturn,
    PATCH: BoardsUpdateReturn,
    PUT: BoardsUpdateReturn,
    DELETE: BoardsDestroyReturn
  }
}
