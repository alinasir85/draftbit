module Response = {
  type t

  @send
  external json: t => Js.Promise.t<Js.Json.t> = "json"

  @send
  external text: t => Js.Promise.t<string> = "text"

  @get
  external ok: t => bool = "ok"

  @get
  external status: t => int = "status"

  @get
  external statusText: t => string = "statusText"
}

type options = {headers: Js.Dict.t<string>, body: option<string>, method: string}

@val
external fetch: (string, options) => Js.Promise.t<Response.t> = "fetch"

let fetchJson = (~headers=Js.Dict.empty(), url: string): Js.Promise.t<Js.Json.t> =>
  fetch(url, {headers: headers, body: None, method: "GET"}) |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )

let patchJson = (~body: option<Js.Json.t>, url: string): Js.Promise.t<Js.Json.t> => {
  let jsonBody = switch body {
  | None => ""
  | Some(b) => Js.Json.stringify(b)
  }
  let updatedHeaders = Js.Dict.empty()
  Js.Dict.set(updatedHeaders, "Content-Type", "application/json")
  fetch(
    url,
    {
      headers: updatedHeaders,
      method: "PATCH",
      body: Some(jsonBody),
    },
  ) |> Js.Promise.then_(res =>
    if !Response.ok(res) {
      res->Response.text->Js.Promise.then_(text => {
        let msg = `${res->Response.status->Js.Int.toString} ${res->Response.statusText}: ${text}`
        Js.Exn.raiseError(msg)
      }, _)
    } else {
      res->Response.json
    }
  )
}
