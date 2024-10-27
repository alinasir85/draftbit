%raw(`require("./PropertiesPanel.css")`)

module Collapsible = {
  @react.component
  let make = (~title, ~children) => {
    let (collapsed, toggle) = React.useState(() => false)

    <section className="Collapsible">
      <button className="Collapsible-button" onClick={_e => toggle(_ => !collapsed)}>
        <span> {React.string(title)} </span> <span> {React.string(collapsed ? "+" : "-")} </span>
      </button>
      {collapsed ? React.null : <div className="Collapsible-content"> {children} </div>}
    </section>
  }
}

// This component provides a simplified example of fetching JSON data from
// the backend and rendering it on the screen.
module ViewExamples = {
  // Type of the data returned by the /examples endpoint
  type example = {
    id: int,
    some_int: int,
    some_text: string,
  }

  @react.component
  let make = () => {
    let (examples: option<array<example>>, setExamples) = React.useState(_ => None)

    React.useEffect1(() => {
      // Fetch the data from /examples and set the state when the promise resolves
      Fetch.fetchJson(`http://localhost:12346/examples`)
      |> Js.Promise.then_(examplesJson => {
        // NOTE: this uses an unsafe type cast, as safely parsing JSON in rescript is somewhat advanced.
        Js.Promise.resolve(setExamples(_ => Some(Obj.magic(examplesJson))))
      })
      // The "ignore" function is necessary because each statement is expected to return `unit` type, but Js.Promise.then return a Promise type.
      |> ignore
      None
    }, [setExamples])

    <div>
      {switch examples {
      | None => React.string("Loading examples....")
      | Some(examples) =>
        examples
        ->Js.Array2.map(example =>
          React.string(`Int: ${example.some_int->Js.Int.toString}, Str: ${example.some_text}`)
        )
        ->React.array
      }}
    </div>
  }
}

module Input = {
  @react.component
  let make = (~value, ~onChange, ~className="") => {
    <input
      type_="text"
      value
      onChange={e => onChange(ReactEvent.Form.target(e)["value"])}
      className={`input ${className}`}
    />
  }
}

module Prism = {
  @react.component
  let make = () => {
    let (marginTop, setMarginTop) = React.useState(() => "auto")
    let (marginRight, setMarginRight) = React.useState(() => "auto")
    let (marginBottom, setMarginBottom) = React.useState(() => "auto")
    let (marginLeft, setMarginLeft) = React.useState(() => "2pt")
    let (paddingTop, setPaddingTop) = React.useState(() => "auto")
    let (paddingRight, setPaddingRight) = React.useState(() => "auto")
    let (paddingBottom, setPaddingBottom) = React.useState(() => "auto")
    let (paddingLeft, setPaddingLeft) = React.useState(() => "auto")
    <div className="spacing-panel">
      <div className="margin-label"> {React.string("Margin")} </div>
      <div className="padding-box">
        <div className="padding-label"> {React.string("Padding")} </div>
        <Input value=marginTop onChange=setMarginTop className="margin top" />
        <Input value=marginRight onChange=setMarginRight className="margin right" />
        <Input value=marginBottom onChange=setMarginBottom className="margin bottom" />
        <Input value=marginLeft onChange=setMarginLeft className="margin left highlight" />
        <Input value=paddingTop onChange=setPaddingTop className="padding top" />
        <Input value=paddingRight onChange=setPaddingRight className="padding right" />
        <Input value=paddingBottom onChange=setPaddingBottom className="padding bottom" />
        <Input value=paddingLeft onChange=setPaddingLeft className="padding left" />
      </div>
    </div>
  }
}

@genType @genType.as("PropertiesPanel") @react.component
let make = () => {
  <aside className="PropertiesPanel">
    <Collapsible title="Load examples"> <ViewExamples /> </Collapsible>
    <Collapsible title="Margins & Padding"> <Prism /> </Collapsible>
    <Collapsible title="Size"> <span> {React.string("example")} </span> </Collapsible>
  </aside>
}
