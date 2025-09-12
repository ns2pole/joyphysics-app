-- debug_all_props.scpt
set keynotePath to POSIX file "/Users/nakamurashunsuke/Documents/Youtube/joyphysics/lib/mindMap/dynamics.key"

tell application "Keynote"
    open keynotePath
    tell front document
        set slide1 to slide 1
        set nodeList to {}

        repeat with i from 1 to count of (every shape of slide1)
            set o to item i of (every shape of slide1)

            -- 各プロパティを try で安全に取得
            try
                set nm to name of o
            on error
                set nm to ""
            end try

            try
                set oid to id of o
            on error
                set oid to ""
            end try

            try
                set cls to class of o as string
            on error
                set cls to ""
            end try

            try
                set pos to position of o
                set xPos to item 1 of pos
                set yPos to item 2 of pos
            on error
                set xPos to 0
                set yPos to 0
            end try

            try
                set b to bounds of o
            on error
                set b to {0,0,0,0}
            end try

            try
                set w to width of o
            on error
                set w to 0
            end try

            try
                set h to height of o
            on error
                set h to 0
            end try

            try
                set rot to rotation of o
            on error
                set rot to 0
            end try

            try
                set ot to (object text of o) as string
            on error
                set ot to ""
            end try

            -- ハイパーリンク(URL)があれば取ってみる（失敗するクラス多数）
            try
                set theURL to URL of o
            on error
                set theURL to ""
            end try

            -- まとめて node 情報に入れる
            set end of nodeList to {index:i, name:nm, id:oid, class:cls, x:xPos, y:yPos, bounds:b, w:w, h:h, rotation:rot, objectText:ot, url:theURL}
        end repeat

        -- JSON 出力（簡易）
        set jsonString to "["
        repeat with i from 1 to count of nodeList
            set n to item i of nodeList
            set jsonString to jsonString & "{\"index\":" & (index of n) & ",\"name\":\"" & (name of n) & "\",\"id\":\"" & (id of n) & "\",\"class\":\"" & (class of n) & "\",\"x\":" & (x of n) & ",\"y\":" & (y of n) & ",\"w\":" & (w of n) & ",\"h\":" & (h of n) & ",\"rotation\":" & (rotation of n) & ",\"objectText\":\"" & (objectText of n) & "\",\"url\":\"" & (url of n) & "\"}"
            if i < count of nodeList then set jsonString to jsonString & ","
        end repeat
        set jsonString to jsonString & "]"

        return jsonString
    end tell
end tell

