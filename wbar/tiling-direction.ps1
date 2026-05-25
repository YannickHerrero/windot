# Print the current GlazeWM tiling direction as a single character.
# Driven by wbar's [widgets.tiling] command widget (see config.toml).
#
# - horizontal split: '═'  (next window will be placed side-by-side)
# - vertical split:   '║'  (next window will be placed below)
#
# The console encoding is forced to UTF-8 so wbar's from_utf8_lossy
# reads the box-drawing chars correctly.

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
try {
    $resp = & GlazeWM query tiling-direction 2>$null
    if (-not $resp) { return }
    $direction = ($resp | ConvertFrom-Json).tilingDirection
    if ($direction -eq 'horizontal') { '═' } else { '║' }
} catch {
    return
}
