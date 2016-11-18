port module Main exposing (..)

import Test.Runner.Node exposing (run, TestProgram)
import Expect
import Test exposing (..)
import Json.Encode exposing (Value)
import Test.Html.Query as Query
import Test.Html.Query.Criteria exposing (..)
import ExampleApp exposing (view, exampleModel)


main : TestProgram
main =
    [ testText
    ]
        |> Test.concat
        |> run emit


port emit : ( String, Value ) -> Cmd msg


testText : Test
testText =
    describe "working with HTML text"
        [ test "(this should fail) expect header to have 4 links in it, even though it has 3" <|
            \() ->
                view exampleModel
                    |> Query.find [ id "heading" ]
                    |> Query.children [ tag "a" ]
                    |> Query.count (Expect.equal 4)
        ]
