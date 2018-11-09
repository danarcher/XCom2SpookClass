class SpookSoundManager
	extends Object
	config(Spook);

`include(XCom2SpookClass\Src\Spook.uci)

var SoundCue SilencedPistol;

function OnInit()
{
    //SilencedPistol = SoundCue(`CONTENT.LoadObjectFromContentPackage('Spook.SpookSilencedPistolMono_Cue'));
}
