%raw(`require("./PropertiesPanel.css")`)

@genType @genType.as("PropertiesPanel") @react.component
let make = () => {
  <aside className="PropertiesPanel">
    <Collapsible title="Load examples"> <ViewExamples /> </Collapsible>
    <Collapsible title="Margins & Padding"> <Prism /> </Collapsible>
    <Collapsible title="Size"> <span> {React.string("example")} </span> </Collapsible>
  </aside>
}
