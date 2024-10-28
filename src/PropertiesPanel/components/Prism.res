type spacingValues = {
  id: string,
  margin_left: string,
  margin_right: string,
  margin_top: string,
  margin_bottom: string,
  padding_left: string,
  padding_right: string,
  padding_top: string,
  padding_bottom: string,
  is_margin_left_focused: option<bool>,
  is_margin_right_focused: option<bool>,
  is_margin_top_focused: option<bool>,
  is_margin_bottom_focused: option<bool>,
  is_padding_left_focused: option<bool>,
  is_padding_right_focused: option<bool>,
  is_padding_top_focused: option<bool>,
  is_padding_bottom_focused: option<bool>,
}

@react.component
let make = () => {
  let (id, setId) = React.useState(() => None)
  let (marginTop, setMarginTop) = React.useState(() => "")
  let (marginRight, setMarginRight) = React.useState(() => "")
  let (marginBottom, setMarginBottom) = React.useState(() => "")
  let (marginLeft, setMarginLeft) = React.useState(() => "")
  let (paddingTop, setPaddingTop) = React.useState(() => "")
  let (paddingRight, setPaddingRight) = React.useState(() => "")
  let (paddingBottom, setPaddingBottom) = React.useState(() => "")
  let (paddingLeft, setPaddingLeft) = React.useState(() => "")

  let debouncedMarginTop = Hooks.useDebounce(~value=marginTop, ~delay=600)
  let debouncedMarginRight = Hooks.useDebounce(~value=marginRight, ~delay=600)
  let debouncedMarginBottom = Hooks.useDebounce(~value=marginBottom, ~delay=600)
  let debouncedMarginLeft = Hooks.useDebounce(~value=marginLeft, ~delay=600)
  let debouncedPaddingTop = Hooks.useDebounce(~value=paddingTop, ~delay=600)
  let debouncedPaddingRight = Hooks.useDebounce(~value=paddingRight, ~delay=600)
  let debouncedPaddingBottom = Hooks.useDebounce(~value=paddingBottom, ~delay=600)
  let debouncedPaddingLeft = Hooks.useDebounce(~value=paddingLeft, ~delay=600)

  React.useEffect1(() => {
    Fetch.fetchJson(`http://localhost:12346/spacing-values`)
    |> Js.Promise.then_(respJson => {
      let values = respJson->Obj.magic
      Js.log(values)
      setId(_ =>
        switch values.id {
        | "" => None
        | id => Some(id)
        }
      )
      setMarginTop(_ => values.margin_top)
      setMarginRight(_ => values.margin_right)
      setMarginBottom(_ => values.margin_bottom)
      setMarginLeft(_ => values.margin_left)
      setPaddingTop(_ => values.padding_top)
      setPaddingRight(_ => values.padding_right)
      setPaddingBottom(_ => values.padding_bottom)
      setPaddingLeft(_ => values.padding_left)
      Js.Promise.resolve(respJson)
    })
    |> ignore
    None
  }, [])

  React.useEffect1(() => {
    let body = Js.Dict.empty()
    switch id {
    | Some(existingId) => Js.Dict.set(body, "id", Js.Json.string(existingId))
    | None => ()
    }
    Js.Dict.set(body, "marginTop", Js.Json.string(debouncedMarginTop))
    Js.Dict.set(body, "marginRight", Js.Json.string(debouncedMarginRight))
    Js.Dict.set(body, "marginBottom", Js.Json.string(debouncedMarginBottom))
    Js.Dict.set(body, "marginLeft", Js.Json.string(debouncedMarginLeft))
    Js.Dict.set(body, "paddingTop", Js.Json.string(debouncedPaddingTop))
    Js.Dict.set(body, "paddingRight", Js.Json.string(debouncedPaddingRight))
    Js.Dict.set(body, "paddingBottom", Js.Json.string(debouncedPaddingBottom))
    Js.Dict.set(body, "paddingLeft", Js.Json.string(debouncedPaddingLeft))
    let jsonBody = Js.Json.object_(body)

    Fetch.postJson(~body=Some(jsonBody), "http://localhost:12346/spacing-values")
    |> Js.Promise.then_(response => {
      Js.log("Spacing values updated")
      switch Js.Json.decodeObject(response) {
      | Some(obj) =>
        // Attempt to get the "id" field from the JSON object
        let idOption = Js.Dict.get(obj, "id")
        switch idOption {
        | Some(idValue) =>
          // Check if the idValue is a number
          switch Js.Json.decodeNumber(idValue) {
          | Some(number) =>
            let idString = Js.Float.toString(number) // Convert the number to a string
            setId(_prev => Some(idString)) // Set the state with the string
            Js.Promise.resolve(response)
          | None =>
            Js.log("ID is not a valid number")
            Js.Promise.resolve(Js.Json.null)
          }
        | None =>
          Js.log("ID not found in response")
          Js.Promise.resolve(Js.Json.null)
        }
      | None =>
        Js.log("Response is not a valid JSON object")
        Js.Promise.resolve(Js.Json.null)
      }
    })
    |> Js.Promise.catch(err => {
      Js.log2("Error updating spacing values", err)
      Js.Promise.resolve(Js.Json.null)
    })
    |> ignore

    None
  }, [
    debouncedMarginTop,
    debouncedMarginRight,
    debouncedMarginBottom,
    debouncedMarginLeft,
    debouncedPaddingTop,
    debouncedPaddingRight,
    debouncedPaddingBottom,
    debouncedPaddingLeft,
  ])

  <div className="spacing-panel">
    <div className="margin-label"> {React.string("Margin")} </div>
    <div className="padding-box">
      <div className="padding-label"> {React.string("Padding")} </div>
      <SpacingInput value=marginTop setValue=setMarginTop className="margin top" />
      <SpacingInput value=marginRight setValue=setMarginRight className="margin right" />
      <SpacingInput value=marginBottom setValue=setMarginBottom className="margin bottom" />
      <SpacingInput value=marginLeft setValue=setMarginLeft className="margin left" />
      <SpacingInput value=paddingTop setValue=setPaddingTop className="padding top" />
      <SpacingInput value=paddingRight setValue=setPaddingRight className="padding right" />
      <SpacingInput value=paddingBottom setValue=setPaddingBottom className="padding bottom" />
      <SpacingInput value=paddingLeft setValue=setPaddingLeft className="padding left" />
    </div>
  </div>
}
