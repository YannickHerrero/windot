; Center window on screen
CenterWindow(guiObj) {
    guiObj.Show("Hide")
    guiObj.GetPos(, , &width, &height)

    ; Get monitor info for the active monitor
    MonitorGet(MonitorGetPrimary(), &mLeft, &mTop, &mRight, &mBottom)

    x := mLeft + (mRight - mLeft - width) // 2
    y := mTop + (mBottom - mTop - height) // 2

    guiObj.Move(x, y)
}
