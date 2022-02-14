module AnnotatedCounter exposing (..)

import Browser
import Html exposing (Html, a, div, text)
import Html.Attributes exposing (class, classList, href)
import Json.Decode as Decode
import SimpleProgram
import Svg exposing (Svg, animate, animateMotion, circle, ellipse, g, marker, mpath, path, rect, svg)
import Svg.Attributes
    exposing
        ( attributeName
        , begin
        , cx
        , cy
        , d
        , dur
        , dy
        , fill
        , fillOpacity
        , from
        , height
        , id
        , markerEnd
        , markerHeight
        , markerWidth
        , min
        , opacity
        , orient
        , preserveAspectRatio
        , r
        , refX
        , refY
        , rx
        , ry
        , stroke
        , strokeWidth
        , textAnchor
        , to
        , viewBox
        , width
        , x
        , xlinkHref
        , y
        )
import Svg.Events


main =
    Browser.sandbox
        { init = initialState
        , update = update
        , view = view
        }


type alias Model =
    { simpleProgramState : SimpleProgram.Model
    , displayedState : SimpleProgram.Model
    , pendingMessages : List PendingState
    , nextId : Int
    }


type alias PendingState =
    { order : Int
    , msg : SimpleProgram.Msg
    , model : SimpleProgram.Model
    }


initialState : Model
initialState =
    let
        subState =
            SimpleProgram.initialState
    in
    { simpleProgramState = subState
    , displayedState = subState
    , pendingMessages = []
    , nextId = 0
    }



-- Update


type Msg
    = ProgMsg SimpleProgram.Msg
    | UpdateModelDisplay SimpleProgram.Model
    | AnimateComplete PendingState


update : Msg -> Model -> Model
update msg model =
    case msg of
        UpdateModelDisplay newState ->
            { model | displayedState = newState }

        AnimateComplete pendingState ->
            { model
                | simpleProgramState = pendingState.model
                , pendingMessages = List.filter ((==) pendingState >> not) model.pendingMessages
            }

        ProgMsg progMsg ->
            let
                nextState =
                    SimpleProgram.update progMsg model.simpleProgramState
            in
            { model
                | pendingMessages = model.pendingMessages ++ [ PendingState model.nextId progMsg nextState ]
                , nextId = model.nextId + 1
            }


onEnd msg =
    Svg.Events.on "end" (Decode.succeed msg)


view : Model -> Html Msg
view model =
    let
        isAnimating =
            not (List.isEmpty model.pendingMessages)
    in
    div [ classList [ ( "explainer", True ), ( "animating", isAnimating ) ] ]
        [ div [ class "elm-architecture" ]
            ([ svg [ width "100%", height "100%", viewBox "0 0 1000 1200", preserveAspectRatio "xMidYMid" ]
                [ arrowHead
                , section "update" 225 475 "#DDD"
                , section "model" 525 775 "#DDD"
                , section "view" 825 1175 "#DDD"
                , oval ( 500, 350 )
                , oval ( 500, 650 )
                , viewOval ( 500, 1000 )
                , curve "modelUpdateConnector" modelUpdatePath
                , curve "viewUpdateConnector" viewUpdatePath
                , curve "modelViewConnector" modelViewPath
                , curve "updateModelPath" updateModelPath
                , invisible (curve "updateInternalPath" updateInternalPath) []
                , invisible (curve "modelSetPath" modelSetPath) []
                , invisible (curve "modelUpdateAnimationPath" modelUpdateAnimationPath) []
                , modelBlob ( 500, 650 ) 50 "currentState" model.displayedState
                , invisible (curve "modelRenderPath" modelRenderPath) []
                ]
             ]
                ++ List.map (animatedMessage model.displayedState) model.pendingMessages
            )
        , div [ class "app-embed" ]
            [ Html.map ProgMsg <| SimpleProgram.view model.simpleProgramState
            ]
        , div [ class "footnote" ]
            [ a [ href "https://bugs.webkit.org/show_bug.cgi?id=63727" ] [ text "This demo only works in firefox" ] ]
        ]


animatedMessage : SimpleProgram.Model -> PendingState -> Html Msg
animatedMessage currentState pendingState =
    let
        order =
            pendingState.order

        msg =
            pendingState.msg

        model =
            pendingState.model

        msgBlobId =
            "msgBlob" ++ String.fromInt order

        modelBlobId =
            "modelBlob" ++ String.fromInt order

        newModelId =
            "newModel" ++ String.fromInt order

        msgColor =
            case msg of
                SimpleProgram.Increment ->
                    "tomato"

                SimpleProgram.Decrement ->
                    "blue"

        msgClass =
            case msg of
                SimpleProgram.Increment ->
                    "increment"

                SimpleProgram.Decrement ->
                    "decrement"
    in
    svg [ width "100%", height "100%", viewBox "0 0 1000 1200", preserveAspectRatio "xMidYMid" ]
        [ modelBlob ( 0, 0 ) 50 modelBlobId currentState
        , invisible (modelBlob ( 0, 0 ) 50 "" model) [ id newModelId ]
        , msgBlob msgClass msgBlobId
        , animateBlobPath "viewUpdateConnector" msgBlobId [ begin "0s", dur "1.5s", id (msgBlobId ++ "a1") ]
        , animateBlobPath "modelUpdateAnimationPath" modelBlobId [ begin "0s", dur "1.5s", id (modelBlobId ++ "a1") ]
        , animateBlobPath "updateInternalPath" msgBlobId [ begin (msgBlobId ++ "a1.end"), dur "1.5s" ]
        , animateBlobPath "updateInternalPath" modelBlobId [ begin (modelBlobId ++ "a1.end"), dur "1.5s" ]
        , animateBlobPath "updateInternalPath" newModelId [ begin (modelBlobId ++ "a1.end"), dur "1.5s", id (newModelId ++ "a1") ]
        , animateOpacity newModelId "0" "1" [ begin (modelBlobId ++ "a1.end"), dur "1.5s" ]
        , animateOpacity msgBlobId "0.75" "0" [ begin (modelBlobId ++ "a1.end"), dur "1.5s" ]
        , animateOpacity modelBlobId "1" "0" [ begin (modelBlobId ++ "a1.end"), dur "1.5s" ]
        , animateBlobPath "updateModelPath" newModelId [ begin (newModelId ++ "a1.end"), dur "0.5s", id (newModelId ++ "a2") ]
        , animateBlobPath "modelSetPath" newModelId [ begin (newModelId ++ "a2.end"), dur "0.5s", onEnd (UpdateModelDisplay pendingState.model), id (newModelId ++ "a3") ]
        , animateBlobPath "modelRenderPath" newModelId [ begin (newModelId ++ "a3.end"), dur "1.5s", onEnd (AnimateComplete pendingState) ]
        , animateOpacity newModelId "1" "0" [ begin (newModelId ++ "a3.end+0.75s"), dur "0.5s" ]
        ]


msgBlob msgClass blobId =
    circle
        [ id blobId
        , Svg.Attributes.class msgClass
        , r "50"
        , cx "0"
        , cy "0"
        , opacity "0.75"
        ]
        []


animateBlobPath pathId blobId attrs =
    animateMotion
        ([ xlinkHref ("#" ++ blobId)
         , fill "freeze"
         ]
            ++ attrs
        )
        [ mpath [ xlinkHref ("#" ++ pathId) ] [] ]


animateOpacity blobId start end attrs =
    animate
        ([ xlinkHref ("#" ++ blobId)
         , attributeName "opacity"
         , from start
         , to end
         , fill "freeze"
         ]
            ++ attrs
        )
        []


lineColor =
    stroke "#333"


lineWidth =
    strokeWidth "3"


ovalPath : ( Int, Int ) -> ( Int, Int ) -> Int -> String
ovalPath ( startX, startY ) ( endX, endY ) offset =
    let
        bezierX =
            String.fromInt (startX - offset)

        sX =
            String.fromInt startX

        sY =
            String.fromInt startY

        eX =
            String.fromInt endX

        eY =
            String.fromInt endY
    in
    String.join " " [ "M", sX, sY, "C", bezierX, sY, bezierX, eY, eX, eY ]


linePath : ( Int, Int ) -> ( Int, Int ) -> String
linePath ( startX, startY ) ( endX, endY ) =
    String.join " "
        [ "M"
        , String.fromInt startX
        , String.fromInt startY
        , "L"
        , String.fromInt endX
        , String.fromInt endY
        ]


modelUpdatePath : String
modelUpdatePath =
    ovalPath ( 200, 650 ) ( 200, 350 ) 80


viewUpdatePath : String
viewUpdatePath =
    ovalPath ( 5, 1000 ) ( 200, 350 ) 80


modelViewPath : String
modelViewPath =
    linePath ( 500, 750 ) ( 500, 850 )


updateModelPath : String
updateModelPath =
    linePath ( 500, 450 ) ( 500, 550 )


updateInternalPath : String
updateInternalPath =
    internalPath ( 200, 350 ) ( 500, 450 )


modelSetPath : String
modelSetPath =
    linePath ( 500, 550 ) ( 500, 650 )


modelRenderPath : String
modelRenderPath =
    linePath ( 500, 650 ) ( 500, 1000 )


modelUpdateAnimationPath : String
modelUpdateAnimationPath =
    linePath ( 500, 650 ) ( 200, 650 ) ++ modelUpdatePath


internalPath : ( Int, Int ) -> ( Int, Int ) -> String
internalPath ( startX, startY ) ( endX, endY ) =
    String.join
        " "
        [ "M"
        , String.fromInt startX
        , String.fromInt startY
        , "C"
        , String.fromInt (startX + 300)
        , String.fromInt startY
        , String.fromInt endX
        , String.fromInt (endY - 120)
        , String.fromInt endX
        , String.fromInt endY
        ]


curve : String -> String -> Svg Msg
curve identifier pathDef =
    path
        [ id identifier
        , Svg.Attributes.class "curve"
        , d pathDef
        , lineColor
        , lineWidth
        , fill "none"
        , markerEnd "url(#arrow)"
        ]
        []


oval : ( Int, Int ) -> Svg Msg
oval ( xInt, yInt ) =
    let
        xStr =
            String.fromInt xInt

        yStr =
            String.fromInt yInt
    in
    ellipse
        [ Svg.Attributes.class "actionShape"
        , fill "white"
        , lineColor
        , lineWidth
        , cx xStr
        , cy yStr
        , rx "300"
        , ry "100"
        ]
        []


viewOval : ( Int, Int ) -> Svg Msg
viewOval ( xInt, yInt ) =
    let
        xStr =
            String.fromInt xInt

        yStr =
            String.fromInt yInt
    in
    ellipse
        [ Svg.Attributes.class "actionShape"
        , fill "white"
        , lineColor
        , lineWidth
        , cx xStr
        , cy yStr
        , rx "500"
        , ry "150"
        ]
        []


modelBlob : ( Int, Int ) -> Int -> String -> SimpleProgram.Model -> Svg Msg
modelBlob ( xPos, yPos ) radius blobId data =
    g [ id blobId ]
        [ circle
            [ Svg.Attributes.class "modelBlob"
            , r (String.fromInt radius)
            , cx (String.fromInt xPos)
            , cy (String.fromInt yPos)
            , fill "white"
            , lineColor
            , lineWidth
            ]
            []
        , Svg.text_ [ textAnchor "middle", x (String.fromInt xPos), y (String.fromInt yPos), dy "20px" ]
            [ Svg.text (String.fromInt data.count) ]
        ]


invisible : Svg msg -> List (Svg.Attribute msg) -> Svg msg
invisible svg attrs =
    g (opacity "0" :: attrs) [ svg ]


section : String -> Int -> Int -> String -> Svg Msg
section label top bottom color =
    let
        sectionHeight =
            String.fromInt <| bottom - top

        halfway =
            String.fromInt <| ((bottom + top) // 2)
    in
    g []
        [ rect [ Svg.Attributes.class "actionBg", fill color, x "-800", y (String.fromInt top), height sectionHeight, width "3000" ] []
        , Svg.text_ [ Svg.Attributes.class "label", textAnchor "left", x "-300", y halfway, dy "20px" ]
            [ Svg.text label ]
        ]


arrowHead : Svg Msg
arrowHead =
    marker
        [ id "arrow"
        , viewBox "0 0 10 10"
        , refX "5"
        , refY "5"
        , markerWidth "10"
        , markerHeight "10"
        , orient "auto"
        ]
        [ path [ d "M 0 0 L 10 5 L 0 10 z" ] [] ]
