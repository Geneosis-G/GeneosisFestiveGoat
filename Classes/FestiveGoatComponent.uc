class FestiveGoatComponent extends GGMutatorComponent;

var GGGoat gMe;
var GGMutator myMut;

var StaticMeshComponent glassesMesh;
var float fireworkOffset;

/**
 * See super.
 */
function AttachToPlayer( GGGoat goat, optional GGMutator owningMutator )
{
	super.AttachToPlayer(goat, owningMutator);

	if(mGoat != none)
	{
		gMe=goat;
		myMut=owningMutator;

		glassesMesh.SetLightEnvironment( gMe.mesh.LightEnvironment );
		gMe.mesh.AttachComponentToSocket( glassesMesh, 'hairSocket' );
	}
}

function KeyState( name newKey, EKeyState keyState, PlayerController PCOwner )
{
	local GGPlayerInputGame localInput;

	if(PCOwner != gMe.Controller)
		return;

	localInput = GGPlayerInputGame( PCOwner.PlayerInput );

	if( keyState == KS_Down )
	{
		if( localInput.IsKeyIsPressed( "GBA_Special", string( newKey ) ) )
		{
			if(gMe.Physics == PHYS_Walking || gMe.Physics == PHYS_Spider)
			{
				MakeFireworks();
			}
		}
	}
}

function MakeFireworks()
{
	local vector pos;
	local float r, h;
	local rotator newRotation;

	gMe.GetBoundingCylinder(r, h);
	newRotation = rotator( gMe.Mesh.GetBoneAxis( gMe.mStandUpBoneName, AXIS_X ));
	newRotation.Pitch+=13000.f;
	pos=gMe.Location + Normal(vector(gMe.Rotation))*(r+fireworkOffset);
	myMut.Spawn(class'ActivableFirework',,, pos, newRotation,,true);
	//myMut.WorldInfo.Game.Broadcast(myMut, "new firework=" $ af);
}

defaultproperties
{
	fireworkOffset=100.f

	Begin Object class=StaticMeshComponent Name=StaticMeshComp1
		StaticMesh=StaticMesh'Hats.Mesh.SwagGlasses'
	End Object
	glassesMesh=StaticMeshComp1
}