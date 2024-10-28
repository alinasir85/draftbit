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

module Window = {
  @scope("window") @val
  external alert: string => unit = "alert"
}

let isHighlight = (value: string) => value !== "" && value !== "auto"

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
  let (isInitialLoad, setIsInitialLoad) = React.useState(() => true)

  let debouncedMarginTop = Hooks.useDebounce(~value=marginTop, ~delay=600)
  let debouncedMarginRight = Hooks.useDebounce(~value=marginRight, ~delay=600)
  let debouncedMarginBottom = Hooks.useDebounce(~value=marginBottom, ~delay=600)
  let debouncedMarginLeft = Hooks.useDebounce(~value=marginLeft, ~delay=600)
  let debouncedPaddingTop = Hooks.useDebounce(~value=paddingTop, ~delay=600)
  let debouncedPaddingRight = Hooks.useDebounce(~value=paddingRight, ~delay=600)
  let debouncedPaddingBottom = Hooks.useDebounce(~value=paddingBottom, ~delay=600)
  let debouncedPaddingLeft = Hooks.useDebounce(~value=paddingLeft, ~delay=600)

  let prevDepsRef = React.useRef([
    debouncedMarginTop,
    debouncedMarginRight,
    debouncedMarginBottom,
    debouncedMarginLeft,
    debouncedPaddingTop,
    debouncedPaddingRight,
    debouncedPaddingBottom,
    debouncedPaddingLeft,
  ])

  let createBodyForChangedValue = (
    ~prevDeps: array<string>,
    ~currentDeps: array<string>,
    ~fieldNames: array<string>,
  ) => {
    let body = Js.Dict.empty()

    switch id {
    | Some(existingId) => Js.Dict.set(body, "id", Js.Json.string(existingId))
    | None => ()
    }

    Belt.Array.forEachWithIndex(currentDeps, (index, currentValue) => {
      let prevValue = prevDeps[index]
      let isCurrentValueValid = switch Js.Nullable.fromOption(Some(currentValue)) {
      | value if value === Js.Nullable.null => false
      | _ => currentValue !== ""
      }

      if currentValue !== prevValue && isCurrentValueValid {
        Js.Dict.set(body, fieldNames[index], Js.Json.string(currentValue))
      }
    })

    body
  }

  React.useEffect1(() => {
    Fetch.fetchJson(`http://localhost:12346/spacing-values`)
    |> Js.Promise.then_(respJson => {
      let values = respJson->Obj.magic
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

      prevDepsRef.current = [
        values.margin_top,
        values.margin_right,
        values.margin_bottom,
        values.margin_left,
        values.padding_top,
        values.padding_right,
        values.padding_bottom,
        values.padding_left,
      ]

      Js.Global.setTimeout(() => {
        setIsInitialLoad(_ => false)
      }, 700)->ignore

      Js.Promise.resolve(respJson)
    })
    |> ignore
    None
  }, [])

  React.useEffect1(() => {
    if !isInitialLoad {
      let currentDeps = [
        debouncedMarginTop,
        debouncedMarginRight,
        debouncedMarginBottom,
        debouncedMarginLeft,
        debouncedPaddingTop,
        debouncedPaddingRight,
        debouncedPaddingBottom,
        debouncedPaddingLeft,
      ]
      let fieldNames = [
        "marginTop",
        "marginRight",
        "marginBottom",
        "marginLeft",
        "paddingTop",
        "paddingRight",
        "paddingBottom",
        "paddingLeft",
      ]

      let hasChanges = Belt.Array.reduceWithIndex(currentDeps, false, (acc, curr, idx) => {
        acc || curr !== prevDepsRef.current[idx]
      })

      if hasChanges {
        let body = createBodyForChangedValue(
          ~prevDeps=prevDepsRef.current,
          ~currentDeps,
          ~fieldNames,
        )
        if Js.Dict.keys(body)->Belt.Array.length > (id->Belt.Option.isSome ? 1 : 0) {
          let jsonBody = Js.Json.object_(body)
          Fetch.patchJson(
            ~body=Some(jsonBody),
            `http://localhost:12346/spacing-values/${id->Belt.Option.getWithDefault("")}`,
          )
          |> Js.Promise.then_(response => {
            switch Js.Json.decodeObject(response) {
            | Some(obj) =>
              switch Js.Dict.get(obj, "id") {
              | Some(idValue) =>
                switch Js.Json.decodeNumber(idValue) {
                | Some(number) =>
                  let idString = Js.Float.toString(number)
                  setId(_prev => Some(idString))
                  Window.alert("Spacing values updated successfully!")
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

          prevDepsRef.current = currentDeps
        }
      }
    }
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
      <SpacingInput
        value=marginTop
        setValue=setMarginTop
        className={`margin top ${isHighlight(marginTop) ? "highlight" : ""} `}
      />
      <SpacingInput
        value=marginRight
        setValue=setMarginRight
        className={`margin right ${isHighlight(marginRight) ? "highlight" : ""} `}
      />
      <SpacingInput
        value=marginBottom
        setValue=setMarginBottom
        className={`margin bottom ${isHighlight(marginBottom) ? "highlight" : ""} `}
      />
      <SpacingInput
        value=marginLeft
        setValue=setMarginLeft
        className={`margin left ${isHighlight(marginLeft) ? "highlight" : ""} `}
      />
      <SpacingInput
        value=paddingTop
        setValue=setPaddingTop
        className={`padding top ${isHighlight(paddingTop) ? "highlight" : ""} `}
      />
      <SpacingInput
        value=paddingRight
        setValue=setPaddingRight
        className={`padding right ${isHighlight(paddingRight) ? "highlight" : ""} `}
      />
      <SpacingInput
        value=paddingBottom
        setValue=setPaddingBottom
        className={`padding bottom ${isHighlight(paddingBottom) ? "highlight" : ""} `}
      />
      <SpacingInput
        value=paddingLeft
        setValue=setPaddingLeft
        className={`padding left ${isHighlight(paddingLeft) ? "highlight" : ""} `}
      />
    </div>
  </div>
}
