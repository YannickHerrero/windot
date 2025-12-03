; Simple fuzzy matching function
FuzzyMatch(text, pattern) {
    text := StrLower(text)
    pattern := StrLower(pattern)

    textPos := 1
    for charIndex, char in StrSplit(pattern) {
        textPos := InStr(text, char, , textPos)
        if (!textPos) {
            return false
        }
        textPos++
    }
    return true
}
