#!/bin/sh
set -e

float_scale=10
function float_eval()
{
    local stat=0
    local result=0.0
    if [[ $# -gt 0 ]]; then
        result=$(echo "scale=$float_scale; $*" | bc -q 2>/dev/null)
        stat=$?
        if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
    fi
    echo $result
    return $stat
}


INPUT="$1"
shift
OUTPUT="$1"
shift
VIDEO_BIT_RATE=1800k
AUDIO_BIT_RATE=64k
ACODEC="-acodec libmp3lame"
VCODEC="-r 65535/2733 -vcodec mpeg4 -vtag XVID"

H=272
echo "Format? 1=16:9 2=4:3"
read F
case $F in
	1)	
		ASPECT=$(float_eval '16 / 9')
		;;
	*)
		ASPECT=$(float_eval '4 / 3')
		;;
esac
W=$(float_eval "272 * $ASPECT" | awk '{printf("%d\n",$1 + 0.5)}')

CMD="ffmpeg -i \"$INPUT\" $VCODEC -q:v 3 -s ${W}x${H} -aspect ${ASPECT} $ACODEC -y -ab $AUDIO_BIT_RATE $@ \"$OUTPUT\""
#CMD="ffmpeg -i \"$INPUT\" $VCODEC -q:v 3 -vf \"scale=$W:$H\" $ACODEC -y -ab $AUDIO_BIT_RATE $@ \"$OUTPUT\""
#CMD="ffmpeg -i \"$INPUT\" $VCODEC -q:v 3 -vf \"scale=trunc(oh/a/2)*2:272\" $ACODEC -y -ab $AUDIO_BIT_RATE $@ \"$OUTPUT\""

echo "=========="
echo "ACHTUNG:"
echo "Um die Länge und Start anzugeben noch die Optionen -ss und -t übergeben"
echo "Benjamin Benjamin : 25min -> 1500"
echo "Heidi : 24min -> 1440"
echo "z.B.: Benjamin Blümchen ab 25 Sekunden ganz zu konvertieren (25min)"
echo "=> -ss 25 -t 1500"
echo "=========="
echo "Aktueller Befehl:"
echo $CMD
echo "Weitermachen?"
read
eval $CMD
