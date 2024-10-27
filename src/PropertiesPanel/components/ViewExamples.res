// This component provides a simplified example of fetching JSON data from
// the backend and rendering it on the screen.
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