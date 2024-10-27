@react.component
let make = (~value: string, ~setValue: (string => string) => unit, ~className="") => {
  let (numericValue, setNumericValue) = React.useState(() => value)
  let (unit, setUnit) = React.useState(() => "pt")
  let (showSelect, setShowSelect) = React.useState(() => false)

  let handleValueChange = (newValue: string) => {
    setNumericValue(_ => newValue)
    setValue(_prev => newValue ++ unit)
  }

  let handleUnitChange = e => {
    let newUnit = ReactEvent.Form.target(e)["value"]
    setUnit(_ => newUnit)
    setValue(_prev => numericValue ++ newUnit)
  }

  let handleInputMouseEnter = (_: ReactEvent.Mouse.t) => {
    setShowSelect(_prev => true)
  }

  let handleInputMouseLeave = (_: ReactEvent.Mouse.t) => {
    if numericValue == "" {
      setShowSelect(_prev => false)
    }
  }

  <div
    className={`input-group ${className}`}
    onMouseLeave={handleInputMouseLeave}
    onMouseEnter={handleInputMouseEnter}>
    <input
      type_="text"
      value=numericValue
      placeholder={"auto"}
      onChange={e => handleValueChange(ReactEvent.Form.target(e)["value"])}
      className="input"
    />
    {showSelect
      ? <select className="input-unit" value=unit onChange={handleUnitChange}>
          <option value="pt"> {React.string("pt")} </option>
          <option value="%"> {React.string("%")} </option>
        </select>
      : <> </>}
  </div>
}
