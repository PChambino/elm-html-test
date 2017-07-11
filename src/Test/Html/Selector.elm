module Test.Html.Selector
    exposing
        ( Selector
        , all
        , attribute
        , checked
        , class
        , classes
        , disabled
        , exactClassName
        , id
        , selected
        , style
        , tag
        , text
        )

{-| Selecting HTML elements.

@docs Selector


## General Selectors

@docs tag, text, attribute, all


## Attributes

@docs id, class, classes, exactClassName, style, checked, selected, disabled

-}

import Dict exposing (Dict)
import ElmHtml.InternalTypes
import Html exposing (Attribute)
import Html.Inert
import Test.Html.Selector.Internal as Internal exposing (..)


{-| A selector used to filter sets of elements.
-}
type alias Selector =
    Internal.Selector


{-| Combine the given selectors into one which requires all of them to match.

    import Html
    import Html.Attributes as Attr
    import Test.Html.Query as Query
    import Test exposing (test)
    import Test.Html.Selector exposing (class, text, all, Selector)


    replyBtnSelector : Selector
    replyBtnSelector =
        all [ class "btn", text "Reply" ]


    test "Button has the class 'btn' and the text 'Reply'" <|
        \() ->
            Html.button [ Attr.class "btn btn-large" ] [ Html.text "Reply" ]
                |> Query.fromHtml
                |> Query.has [ replyBtnSelector ]

-}
all : List Selector -> Selector
all =
    All


{-| Matches elements that have all the given classes (and possibly others as well).

When you only care about one class instead of several, you can use
[`class`](#class) instead of passing this function a list with one value in it.

To match the element's exact class attribute string, use [`className`](#className).

    import Html
    import Html.Attributes as Attr
    import Test.Html.Query as Query
    import Test exposing (test)
    import Test.Html.Selector exposing (classes)


    test "Button has the classes btn and btn-large" <|
        \() ->
            Html.button [ Attr.class "btn btn-large" ] [ Html.text "Reply" ]
                |> Query.fromHtml
                |> Query.has [ classes [ "btn", "btn-large" ] ]

-}
classes : List String -> Selector
classes =
    Classes


{-| Matches elements that have the given class (and possibly others as well).

To match multiple classes at once, use [`classes`](#classes) instead.

To match the element's exact class attribute string, use [`className`](#className).

    import Html
    import Html.Attributes as Attr
    import Test.Html.Query as Query
    import Test exposing (test)
    import Test.Html.Selector exposing (class)


    test "Button has the class btn-large" <|
        \() ->
            Html.button [ Attr.class "btn btn-large" ] [ Html.text "Reply" ]
                |> Query.fromHtml
                |> Query.has [ class "btn-large" ]

-}
class : String -> Selector
class =
    Class


{-| Matches the element's exact class attribute string.

This is used less often than [`class`](#class), [`classes`](#classes) or
[`attribute`](#attribute), which check for the *presence* of a class as opposed
to matching the entire class attribute exactly.

    import Html
    import Html.Attributes as Attr
    import Test.Html.Query as Query
    import Test exposing (test)
    import Test.Html.Selector exposing (exactClassName)


    test "Button has the exact class 'btn btn-large'" <|
        \() ->
            Html.button [ Attr.class "btn btn-large" ] [ Html.text "Reply" ]
                |> Query.fromHtml
                |> Query.has [ exactClassName "btn btn-large" ]

-}
exactClassName : String -> Selector
exactClassName =
    namedAttr "className"


{-| Matches elements that have the given `id` attribute.

    import Html
    import Html.Attributes as Attr
    import Test.Html.Query as Query
    import Test exposing (test)
    import Test.Html.Selector exposing (id, text)


    test "the welcome <h1> says hello!" <|
        \() ->
            Html.div []
                [ Html.h1 [ Attr.id "welcome" ] [ Html.text "Hello!" ] ]
                |> Query.fromHtml
                |> Query.find [ id "welcome" ]
                |> Query.has [ text "Hello!" ]

-}
id : String -> Selector
id =
    namedAttr "id"


{-| Matches elements that have the given tag.

    import Html
    import Html.Attributes as Attr
    import Test.Html.Query as Query
    import Test exposing (test)
    import Test.Html.Selector exposing (tag, text)


    test "the welcome <h1> says hello!" <|
        \() ->
            Html.div []
                [ Html.h1 [ Attr.id "welcome" ] [ Html.text "Hello!" ] ]
                |> Query.fromHtml
                |> Query.find [ tag "h1" ]
                |> Query.has [ text "Hello!" ]

-}
tag : String -> Selector
tag name =
    Tag name


{-| Matches elements that have the given attribute in a way that makes sense
given their semantics in `Html`.

See [Selecting elements by `Html.Attribute msg` in the README](http://package.elm-lang.org/packages/eeue56/elm-html-test/latest#selecting-elements-by-html-attribute-msg-)

-}
attribute : Attribute Never -> Selector
attribute attr =
    let
        facts =
            Html.div [ attr ] []
                |> Html.Inert.findFacts
                |> Maybe.withDefault ElmHtml.InternalTypes.emptyFacts

        name =
            Html.Inert.attributeName attr

        attributeType =
            Html.Inert.attributeType attr
    in
        if attributeType == Html.Inert.Style then
            facts.styles
                |> Dict.toList
                |> Style
        else if String.toLower name == "class" && attributeType == Html.Inert.Attribute then
            facts.stringAttributes
                |> Dict.get name
                |> Maybe.map (String.split " ")
                |> Maybe.withDefault []
                |> Classes
        else if name == "className" && attributeType == Html.Inert.Property then
            facts.stringAttributes
                |> Dict.get "className"
                |> Maybe.map (String.split " ")
                |> Maybe.withDefault []
                |> Classes
        else if attributeType == Html.Inert.Attribute then
            findAttributeInFacts name facts
        else if attributeType == Html.Inert.Property then
            findAttributeInFacts name facts
        else
            Invalid


{-| Matches elements that have all the given style properties (and possibly others as well).

    import Html
    import Html.Attributes as Attr
    import Test.Html.Query as Query
    import Test exposing (test)
    import Test.Html.Selector exposing (classes)


    test "the Reply button has red text" <|
        \() ->
            Html.div []
                [ Html.button [ Attr.style [ ( "color", "red" ) ] ] [ Html.text "Reply" ] ]
                |> Query.has [ style [ ( "color", "red" ) ] ]

-}
style : List ( String, String ) -> Selector
style style =
    Style style


{-| Matches elements that have a
[`text`](http://package.elm-lang.org/packages/elm-lang/html/latest/Html-Attributes#text)
attribute with the given value.
-}
text : String -> Selector
text =
    Internal.Text


{-| Matches elements that have a
[`selected`](http://package.elm-lang.org/packages/elm-lang/html/latest/Html-Attributes#selected)
attribute with the given value.
-}
selected : Bool -> Selector
selected =
    namedBoolAttr "selected"


{-| Matches elements that have a
[`disabled`](http://package.elm-lang.org/packages/elm-lang/html/latest/Html-Attributes#disabled)
attribute with the given value.
-}
disabled : Bool -> Selector
disabled =
    namedBoolAttr "disabled"


{-| Matches elements that have a
[`checked`](http://package.elm-lang.org/packages/elm-lang/html/latest/Html-Attributes#checked)
attribute with the given value.
-}
checked : Bool -> Selector
checked =
    namedBoolAttr "checked"



-- HELPERS


findAttributeInFacts : String -> ElmHtml.InternalTypes.Facts a -> Selector
findAttributeInFacts name facts =
    facts.stringAttributes
        |> Dict.get name
        |> Maybe.map (namedAttr name)
        |> orElseLazy
            (\_ ->
                facts.boolAttributes
                    |> Dict.get name
                    |> Maybe.map (namedBoolAttr name)
            )
        |> Maybe.withDefault Invalid


orElseLazy : (() -> Maybe a) -> Maybe a -> Maybe a
orElseLazy fma mb =
    case mb of
        Nothing ->
            fma ()

        Just _ ->
            mb
