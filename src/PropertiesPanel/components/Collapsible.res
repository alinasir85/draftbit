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
