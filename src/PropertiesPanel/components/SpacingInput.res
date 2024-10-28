@react.component
let make = (~value: string, ~setValue: (string => string) => unit, ~className="") => {
  let (numericValue, setNumericValue) = React.useState(() => value)
  let (unit, setUnit) = React.useState(() => "pt")
  let (showSelect, setShowSelect) = React.useState(() => false)

  let extractValueAndUnit = value => {
    let numericMatch = value->Js.String2.match_(%re("/^[0-9]+/"))
    let unitMatch = value->Js.String2.match_(%re("/[a-z%]+$/i"))
    switch (numericMatch, unitMatch) {
    | (Some([numStr]), Some([unit])) => {
        let num = numStr
        (num, unit)
      }
    | _ => ("", "pt")
    }
  }

  React.useEffect1(() => {
    switch value {
    | "" => None
    | nonEmptyValue => {
        let (num, extractedUnit) = nonEmptyValue->extractValueAndUnit
        setNumericValue(_ => num)
        setUnit(_ => extractedUnit)
        setShowSelect(_ => true)
        None
      }
    }
  }, [value])

  let isValidNumber = (value: string): bool => {
    let numericRegex = %re("/^$|^[0-9]*\.?[0-9]*$/")
    Js.Re.test_(numericRegex, value)
  }

  let handleValueChange = (newValue: string) => {
    if isValidNumber(newValue) {
      setNumericValue(_ => newValue)
      setValue(_prev =>
        switch newValue {
        | "" => "auto"
        | value => value ++ unit
        }
      )
    }
  }

  let handleUnitChange = e => {
    let newUnit = ReactEvent.Form.target(e)["value"]
    setUnit(_ => newUnit)
    setValue(_prev =>
      switch numericValue {
      | "" => "auto"
      | value => value ++ newUnit
      }
    )
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
      placeholder="auto"
      onChange={e => handleValueChange(ReactEvent.Form.target(e)["value"])}
      className="input"
    />
    {showSelect
      ? <select className="input-unit" value=unit onChange={handleUnitChange}>
          <option value="pt"> {React.string("pt")} </option>
          <option value="%"> {React.string("%")} </option>
        </select>
      : React.null}
  </div>
}
