module Main exposing (main)

{-| The main module

@docs main

-}

import Css exposing (hex, rem, rgba)
import Html.Styled exposing (a, div, h1, text)
import Html.Styled.Attributes exposing (href, target)
import Slides exposing (..)
import Slides.Styles as Styles exposing (elmMinimalist)


{-| The program
-}
main : Program () Model Msg
main =
    Slides.app
        options
        [ md
            """
        # What is Elm?

         - A programming language (surprise!)
         - Designed for building interactive applications
         - Designed for saftey and robustness
         - Designed for approachability & ease of learning
         - Part of the ML family of languages (Haskell, OCaml)
         - Compiles to Javascript
        """
        , md
            """
        # What isn't Elm?

        - A "better javascript"
        """
        , md
            """
        # What are the fundamental building blocks of a program?
            """
        , md
            """
        # Functions
        """
        , md
            """
        ### Stateless & Isolated

        ```elm
        -- Everything is an expression, so there's no need for 'return'
        add x y =
            x + y
        ```
        These don't work:
        ```elm
        -- A function's result will always be the same for the same input
        add x y =
            x + y + externalMutableState
        ```

        ```elm
        -- Functions can't silently trigger side-effects
        add x y =
            deleteUser "joe"
            x + y
        ```
        """
        , md
            """
        ### Optional type annotations

        ```elm
        -- Int goes in, Int goes in, Int comes out
        add : Int -> Int -> Int
        add x y
            = x + y
        ```

        ```elm
        -- Lower-case types are type variables, similar to genrics.
        -- Array t in TypeScript would be Array<T>
        first : Array t -> Maybe t
        first array =
            Array.get 0 array
        ```

        ```elm
        -- The last type here is a tuple.
        -- It's a fixed-length ordered grouping of different types
        -- Max tuple size is 3
        update : Msg -> Model -> (Model, Cmd Msg)
        update msg model =
            ...
        ```
        """
        , md
            """
        ### Using Functions
        
        ```elm
        add : Int -> Int -> Int
        add x y
            = x + y
        ```

        Spaces separate a function and it's arguments from each other
        
        ```elm
        -- returns 7
        add 4 3
        ```

        Functions in Elm are curried. 
        It's like an automatic `Function.prototype.bind`

        ```elm
        add5 : Int -> Int
        add5 = add 5

        -- returns 7
        add5 2
        ```
        """
        , md
            """
        # Records

        A little like type-checked objects in js
        """
        , md
            """
        ### Defining & Creating Records

        ```elm
        -- This gives the record described below the short name of 'Person'
        type alias Person =
            { name : String
            , age : Int
            , weight : Float
            }

        -- The compiler will make sure you get the fields right
        bob : Person
        bob =
            { name = "Bob Jones"
            , age = 30
            , weight = 173.5
            }
            
        -- A constructor function is also created. The order of arguments
        -- is the order of fields in the type definition.
        bob = Person "Bob Jones" 30 173.5
        ```
        """
        , md
            """
        ### Reading & Changing Records

        ```elm
        -- You can use dot syntax to access record values
        bobAge = bob.age

        -- It's syntactic sugar for a compiler generated `.age` function
        bobAge = .age bob
        
        -- Which comes in handy dealing with collections
        groupAges = List.map .age groupMembers

        -- There's an 'update' syntax but all values are immutable.
        -- This returns a new record.
        bobClone = { bob | age = 0, name = "Bob 2" }
        ```
        """
        , md
            """
        # Custom Types

        Like enums with extra data
        """
        , md
            """
        ```elm
        -- This is literally how bool is defined in the language
        type Bool
            = True
            | False

        -- Custom types are good when you need to represent 
        -- mutually-exclusive states or different types in the same role
        type PlaneOccupant
            = Traveler Person
            | Cargo Luggage

        -- There are built-in types ore libraries for the most common cases,
        -- like error handling
        type Result error value
            = Ok value
            | Err error

        -- Or the absence of a value, since there's no null in Elm
        type Maybe a
            = Just a
            | Nothing

        -- Or fetching data from an external source
        type RemoteData err val
            = NotAsked
            | Loading
            | Failure err
            | Success val
        ```
        """
        , md
            """
        ### Using Custom Types

        ```elm
        -- Pattern matching lets you destructure any custom type
        showParseResult : Result String Int -> Html msg
        showParseResult result =
            case result of

                Ok value ->
                    text ("Parsed: " ++ (String.fromInt value))

                Err errMsg ->
                    text ("Bad input: " ++ errMsg)
        
        -- But helper functions are also commonly used
        showParseResult : Result String Int -> Html msg
        showParseResult result =
            result |> Result.unpack
                (\\errMsg -> text ("Bad input: " ++ errMsg))
                (\\int -> text ("Parsed: " ++ (String.fromInt value)))
        ```
        """
        , md
            """
        ```elm
        -- Custom types simplify logic, and avoid implicit behaviors
        -- Key to making impossible states impossible
        userView : RemoteData Http.Error User -> Html msg
        userView userRequest =
            case userRequest of

                -- Compiler will error if any case is not handled
                NotAsked ->
                    button [ onClick LoadUser ]
                        [ text "Click to load user" ]

                Loading ->
                    showSpinner

                Success user ->
                    userProfile user

                Failure error ->
                    div [ class "error" ]
                        [ div [] [ text "Error loading user!" ]
                        , div [] [ httpErrorDetails error ]
                        ]
        ```

        """
        , md
            """
        # The Elm Architecture (TEA)

        Stuff gets weird
        """
        , md
            """
        ### Only one(ish) way to structure an application in Elm

        ```elm
        -- Program definition:
        main =
            Browser.element
                { init = init
                , update = update
                , view = view
                , subscriptions = subs
                }

        -- Reads arguments (flags), sets initial state, runs side-effects
        init : flags -> (model, Cmd msg)

        -- When something happens (msg), updates state (model), triggers effects
        update : msg -> model -> (model, Cmd msg)

        -- Renders the state (model) to the DOM
        view : model -> Html msg

        -- Subscribes to external events (time, push events)
        subs: model -> Sub msg
        ```

        `msg`, `model`, `flags` are developer-defined types
        """
        , html
            (div []
                [ h1 [] [ text "Let's see it in action!" ]
                , div []
                    [ a [ href "simple-explainer.html", target "_blank" ]
                        [ text "Simple Version" ]
                    ]
                , div []
                    [ a [ href "giphy-explainer.html", target "_blank" ]
                        [ text "Complex Version" ]
                    ]
                ]
            )
        ]


options =
    { slidesDefaultOptions
        | style = elmMinimalist (hex "#051025") (rgba 0 0 0 0) (rem 1.8) (hex "#c8c5f1")
    }
