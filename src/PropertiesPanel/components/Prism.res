@react.component
let make = () => {
  let (marginTop, setMarginTop) = React.useState(() => "")
  let (marginRight, setMarginRight) = React.useState(() => "")
  let (marginBottom, setMarginBottom) = React.useState(() => "")
  let (marginLeft, setMarginLeft) = React.useState(() => "")
  let (paddingTop, setPaddingTop) = React.useState(() => "")
  let (paddingRight, setPaddingRight) = React.useState(() => "")
  let (paddingBottom, setPaddingBottom) = React.useState(() => "")
  let (paddingLeft, setPaddingLeft) = React.useState(() => "")

  let deps = React.useMemo1(() => {
    (
      marginTop,
      marginRight,
      marginBottom,
      marginLeft,
      paddingTop,
      paddingRight,
      paddingBottom,
      paddingLeft,
    )
  }, [
    marginTop,
    marginRight,
    marginBottom,
    marginLeft,
    paddingTop,
    paddingRight,
    paddingBottom,
    paddingLeft,
  ])

  React.useEffect1(() => {
    Js.log2("Margins:", (marginTop, marginRight, marginBottom, marginLeft))
    Js.log2("Paddings:", (paddingTop, paddingRight, paddingBottom, paddingLeft))
    None
  }, [deps])

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
