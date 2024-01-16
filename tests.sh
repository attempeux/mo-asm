# ---------------------------------------------------#
# File created by Attempeux on Jan 16 2023 program.  #
# Unit tests.                                        #
# ---------------------------------------------------#

#! /usr/bin/env bats

@test "text to morse (1)" {
    run="$(./moasm T "hi")"
    expc="$(echo ".... .. ")"
    [[ "$run" == "$expc" ]]
}

@test "text to morse (2)" {
    run="$(./moasm T "bonjour")"
    expc="$(echo "-... --- -. .--- --- ..- .-. ")"
    [[ "$run" == "$expc" ]]
}

@test "text to morse (3)" {
    run="$(./moasm T "Debut a buenos aires")"
    expc="$(echo "-.. . -... ..- - / .- / -... ..- . -. --- ... / .- .. .-. . ... ")"
    [[ "$run" == "$expc" ]]
}

@test "text to morse (4)" {
    run="$(./moasm T "Made in assembly x86_64")"
    expc="$(echo "-- .- -.. . / .. -. / .- ... ... . -- -... .-.. -.-- / -..- 86_64")"
    [[ "$run" == "$expc" ]]
}

@test "text to morse (5)" {
    run="$(./moasm T "Sors le biff de ta petite tete jsuis venu chanter lvrai frere")"
    expc="$(echo "... --- .-. ... / .-.. . / -... .. ..-. ..-. / -.. . / - .- / .--. . - .. - . / - . - . / .--- ... ..- .. ... / ...- . -. ..- / -.-. .... .- -. - . .-. / .-.. ...- .-. .- .. / ..-. .-. . .-. . ")"
    [[ "$run" == "$expc" ]]
}

@test "morse to text (1)" {
    run="$(./moasm M ".-- .. -.- .. .--. . -.. .. .- ")"
    expc="$(echo "wikipedia")"
    [[ "$run" == "$expc" ]]
}

@test "morse to text (2)" {
    run="$(./moasm M ".-.. .- / ...- .. . / . ... - / -... . .-.. .-.. . ")"
    expc="$(echo "la vie est belle")"
    [[ "$run" == "$expc" ]]
}

@test "morse to text (3)" {
    run="$(./moasm M "- .... .. ... / .. ... / -- --- .-. ... . / -.-. --- -.. . ")"
    expc="$(echo "this is morse code")"
    [[ "$run" == "$expc" ]]
}

@test "morse to text (4)" {
    run="$(./moasm M "... --- .-. ... / .-.. . / -... .. ..-. ..-. / -.. . / - .- / .--. . - .. - . / - . - . / .--- ... ..- .. ... / ...- . -. ..- / -.-. .... .- -. - . .-. / .-.. ...- .-. .- .. / ..-. .-. . .-. . ")"
    echo ">" "$run"
    expc="$(echo "sors le biff de ta petite tete jsuis venu chanter lvrai frere")"
    [[ "$run" == "$expc" ]]
}

@test "morse to text (5)" {
    run="$(./moasm M ".-- . / .-.. --- ...- . / .- ... -- ")"
    expc="$(echo "we love asm")"
    [[ "$run" == "$expc" ]]
}
