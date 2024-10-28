let useDebounce = (~value: string, ~delay: int) => {
  let (debouncedValue, setDebouncedValue) = React.useState(() => value)

  React.useEffect1(() => {
    let timer = Js.Global.setTimeout(() => {
      setDebouncedValue(_prev => value)
    }, delay)

    let cleanup = () => {
      Js.Global.clearTimeout(timer)
    }

    Some(cleanup)
  }, [value, Belt.Int.toString(delay)])

  debouncedValue
}
