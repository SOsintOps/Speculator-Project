#!/usr/bin/env bash
################################################################################
## Video Download and Processing Launcher
## Version 0.1.0 - Phase B: Zenity GUI for yt-dlp, streamlink, gallery-dl, ffmpeg
################################################################################

set -uo pipefail

[ "$XDG_SESSION_TYPE" = "wayland" ] && export GDK_BACKEND=x11

###############################################################################
# Section 1: Video Downloader
###############################################################################

run_video_downloader() {
    local url
    url=$(zenity --entry \
        --title="Video Downloader" \
        --text="Enter the video URL:" \
        2> >(grep -v 'GtkDialog' >&2)) || return

    [ -z "$url" ] && return

    local target
    target=$(echo "$url" | sed 's|.*://||;s|/.*||')

    local sessionDir="$HOME/Downloads/evidence/$target"
    mkdir -p "$sessionDir"

    local tool
    tool=$(zenity --list \
        --title="Video Downloader" \
        --text="Select a download tool:" \
        --column="Tool" \
        "yt-dlp (standard)" \
        "yt-dlp (comments + subtitles + description)" \
        "yt-dlp (audio only, mp3)" \
        "streamlink (best quality)" \
        "gallery-dl" \
        2> >(grep -v 'GtkDialog' >&2)) || return

    case "$tool" in
        "yt-dlp (standard)")
            local BIN="$HOME/.local/bin/yt-dlp"
            if [ ! -x "$BIN" ]; then
                zenity --error --text="yt-dlp not found at $BIN. Install it with: pipx install yt-dlp" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            "$BIN" "$url" -o "$sessionDir/%(title)s.%(ext)s" -i
            ;;
        "yt-dlp (comments + subtitles + description)")
            local BIN="$HOME/.local/bin/yt-dlp"
            if [ ! -x "$BIN" ]; then
                zenity --error --text="yt-dlp not found at $BIN. Install it with: pipx install yt-dlp" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            "$BIN" "$url" --write-comments --write-subs --sub-langs all --write-description \
                -o "$sessionDir/%(title)s.%(ext)s" -i
            ;;
        "yt-dlp (audio only, mp3)")
            local BIN="$HOME/.local/bin/yt-dlp"
            if [ ! -x "$BIN" ]; then
                zenity --error --text="yt-dlp not found at $BIN. Install it with: pipx install yt-dlp" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            "$BIN" "$url" -x --audio-format mp3 -o "$sessionDir/%(title)s.%(ext)s"
            ;;
        "streamlink (best quality)")
            local BIN="$HOME/.local/bin/streamlink"
            if [ ! -x "$BIN" ]; then
                zenity --error --text="streamlink not found at $BIN. Install it with: pipx install streamlink" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            "$BIN" "$url" best -o "$sessionDir/stream_$(date +%Y%m%d_%H%M).ts"
            ;;
        "gallery-dl")
            local BIN="$HOME/.local/bin/gallery-dl"
            if [ ! -x "$BIN" ]; then
                zenity --error --text="gallery-dl not found at $BIN. Install it with: pipx install gallery-dl" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            "$BIN" "$url" -d "$sessionDir/gallery-dl/"
            ;;
    esac
}

###############################################################################
# Section 2: Video Utilities (ffmpeg)
###############################################################################

run_video_utilities() {
    local file
    file=$(zenity --file-selection \
        --title="Select video file" \
        2> >(grep -v 'GtkDialog' >&2)) || return

    [ -z "$file" ] && return

    local tool
    tool=$(zenity --list \
        --title="Video Utilities (ffmpeg)" \
        --text="Select an operation:" \
        --column="Operation" \
        "Play (ffplay)" \
        "Convert to mp4" \
        "Extract frames" \
        "Compress (low activity)" \
        "Compress (high activity)" \
        "Extract audio (mp3)" \
        "Rotate video" \
        2> >(grep -v 'GtkDialog' >&2)) || return

    local timestamp
    timestamp=$(date +%Y-%m-%d_%H%M)

    case "$tool" in
        "Play (ffplay)")
            if [ ! -x /usr/bin/ffplay ]; then
                zenity --error --text="ffplay not found. Install it with: sudo apt install ffmpeg" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            /usr/bin/ffplay "$file"
            ;;
        "Convert to mp4")
            if [ ! -x /usr/bin/ffmpeg ]; then
                zenity --error --text="ffmpeg not found. Install it with: sudo apt install ffmpeg" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            /usr/bin/ffmpeg -i "$file" -vcodec mpeg4 "$HOME/Videos/${timestamp}.mp4"
            xdg-open "$HOME/Videos/" >/dev/null 2>&1 &
            ;;
        "Extract frames")
            if [ ! -x /usr/bin/ffmpeg ]; then
                zenity --error --text="ffmpeg not found. Install it with: sudo apt install ffmpeg" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            mkdir -p "$HOME/Videos/${timestamp}-frames"
            /usr/bin/ffmpeg -y -i "$file" -an -r 10 "$HOME/Videos/${timestamp}-frames/img%03d.bmp"
            xdg-open "$HOME/Videos/" >/dev/null 2>&1 &
            ;;
        "Compress (low activity)")
            if [ ! -x /usr/bin/ffmpeg ]; then
                zenity --error --text="ffmpeg not found. Install it with: sudo apt install ffmpeg" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            /usr/bin/ffmpeg -i "$file" -vf "select=gt(scene\,0.003),setpts=N/(25*TB)" \
                "$HOME/Videos/${timestamp}-low.mp4"
            xdg-open "$HOME/Videos/" >/dev/null 2>&1 &
            ;;
        "Compress (high activity)")
            if [ ! -x /usr/bin/ffmpeg ]; then
                zenity --error --text="ffmpeg not found. Install it with: sudo apt install ffmpeg" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            /usr/bin/ffmpeg -i "$file" -vf "select=gt(scene\,0.005),setpts=N/(25*TB)" \
                "$HOME/Videos/${timestamp}-high.mp4"
            xdg-open "$HOME/Videos/" >/dev/null 2>&1 &
            ;;
        "Extract audio (mp3)")
            if [ ! -x /usr/bin/ffmpeg ]; then
                zenity --error --text="ffmpeg not found. Install it with: sudo apt install ffmpeg" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            /usr/bin/ffmpeg -i "$file" -vn -ac 2 -ar 44100 -ab 320k -f mp3 \
                "$HOME/Videos/${timestamp}.mp3"
            xdg-open "$HOME/Videos/" >/dev/null 2>&1 &
            ;;
        "Rotate video")
            if [ ! -x /usr/bin/ffmpeg ]; then
                zenity --error --text="ffmpeg not found. Install it with: sudo apt install ffmpeg" \
                    2> >(grep -v 'GtkDialog' >&2)
                return
            fi
            /usr/bin/ffmpeg -i "$file" -vf transpose=0 "$HOME/Videos/${timestamp}-rotated.mp4"
            xdg-open "$HOME/Videos/" >/dev/null 2>&1 &
            ;;
    esac
}

###############################################################################
# Main
###############################################################################

main() {
    while true; do
        local section
        section=$(zenity --list \
            --title="Video Tools" \
            --text="Select a section:" \
            --column="Section" \
            "Video Downloader" \
            "Video Utilities (ffmpeg)" \
            2> >(grep -v 'GtkDialog' >&2)) || break

        case "$section" in
            "Video Downloader")
                run_video_downloader
                ;;
            "Video Utilities (ffmpeg)")
                run_video_utilities
                ;;
        esac

        zenity --question \
            --title="Video Tools" \
            --text="Run another operation?" \
            2> >(grep -v 'GtkDialog' >&2) || break
    done
}

main
