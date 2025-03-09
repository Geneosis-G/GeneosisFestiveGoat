class ActivableFirework extends SkeletalMeshActor;

var SkeletalMeshComponent mFireworkMesh;
var StaticMeshComponent mStaticFireworkMesh;
var ParticleSystem mFireworksParticleTemplate;
var ParticleSystemComponent mFireworksParticle;
var ParticleSystemComponent mFireParticle;
var AudioComponent mAC;
var SoundCue mFireworksLoopCue;
var SoundCue mFireworksCue;
var RB_Thruster	mThruster;
var bool isReady;
var float fireworkRange;

var Actor mActor;
var GGGoat mGoat;
var GGPawn mPawn;
var GGKActor mKActor;
var GGSVehicle mVehicle;

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	SetPhysics(PHYS_None);
	mFireworkMesh.SetHidden(true);
	mFireParticle.DeactivateSystem();
	mFireParticle.KillParticlesForced();
	isReady=true;
	if(mActor != none)// Fix fireworks not touching first actor
	{
		AttachFireworks();
	}
}


event Touch( Actor other, PrimitiveComponent otherComp, vector hitLocation, vector hitNormal)
{
	super.Touch( other, otherComp, hitLocation, hitNormal );

	if(PrepareToAttach(other))
	{
		AttachFireworks();
	}
}

// Find actors close enough
event Tick(float DeltaTime)
{
	local Actor hitActor;

	super.Tick(DeltaTime);

	foreach OverlappingActors( class'Actor', hitActor, fireworkRange, Location)
	{
		if(PrepareToAttach(hitActor))
		{
			AttachFireworks();
			break;
		}
	}
}

function bool PrepareToAttach(Actor act)
{
	if( mActor == none )
	{
		if(GGGoat(act) != none || GGNpc(act) != none || GGKActor(act) != none || GGSVehicle(act) != none)
		{
			mActor = act;
			mGoat = GGGoat(act);
			mPawn = GGPawn(act);
			mKActor = GGKActor(act);
			mVehicle = GGSVehicle(act);

			return isReady;// Fix invisible fireworks
		}
	}

	return false;
}

/**
 * See super.
 */
function AttachFireworks()
{
	local bool oldCollideActors, oldBlockActors;
	local vector dir;
	local MeshComponent attachMesh;

	if( mActor != none )
	{
		dir=Normal(vector(Rotation));

		mThruster = Spawn( class'RB_Thruster' );
		mThruster.ThrustStrength = 2000;

		oldCollideActors = mThruster.bCollideActors;
		oldBlockActors = mThruster.bBlockActors;
		mThruster.SetCollision(false, false);
		mThruster.SetBase( mActor );
		mThruster.SetRelativeRotation( mThruster.RelativeRotation + rot( 36768.f, 0.f, 0.f ) );
		mThruster.SetCollision( oldCollideActors, oldBlockActors );

		if(mGoat != none)
		{
			mGoat.SetRotation(Rotation);
			SetBase( mGoat,, mGoat.mesh, 'JetPackSocket' );
		}
		else
		{
			SetBase( mActor );
		}

		mAC=CreateAudioComponent( mFireworksLoopCue, false );
		mAC.Play();

		mFireParticle.ActivateSystem( true );

		if(mKActor != none)
		{
			attachMesh=mKActor.StaticMeshComponent;
		}
		else if(mPawn != none)
		{
			attachMesh=mPawn.mesh;
			if(!mPawn.mIsRagdoll)
			{
				mPawn.SetRagdoll(true);
			}
		}
		else if(mVehicle != none)
		{
			attachMesh=mVehicle.mesh;
		}
		mFireworkMesh.SetLightEnvironment( attachMesh.LightEnvironment );
		attachMesh.SetRBLinearVelocity(attachMesh.GetRBLinearVelocity()+dir*800.f);

		mStaticFireworkMesh.SetHidden(true);
		mFireworkMesh.SetHidden(false);
		mThruster.bThrustEnabled=true;

		SetTimer( 4.0f, false, NameOf( ExplodeFirework ) );
		SetTimer( 2.0f, false, NameOf( StopThrust ) );
	}
}

function StopThrust()
{
	if(mAC.IsPlaying())
	{
		mAC.Stop();
	}
	mThruster.bThrustEnabled=false;
	mFireParticle.DeactivateSystem();
}

function ExplodeFirework()
{
	mFireworkMesh.SetHidden(true);

	PlaySound(mFireworksCue, true,,, Location);
	WorldInfo.MyEmitterPool.SpawnEmitter(mFireworksParticleTemplate, Location);

	Destroy();
}

DefaultProperties
{
	fireworkRange=40.f

	Begin Object name=SkeletalMeshComponent0
		SkeletalMesh=SkeletalMesh'Fireworks.mesh.Fireworks'
		PhysicsAsset=PhysicsAsset'Fireworks.mesh.Fireworks_Physics'
	End Object
	mFireworkMesh=SkeletalMeshComponent0

	Begin Object class=StaticMeshComponent name=StaticMeshComponent0
		StaticMesh=StaticMesh'Fireworks.mesh.Fireworks_Rocket'
	End Object
	Components.Add(StaticMeshComponent0)
	mStaticFireworkMesh=StaticMeshComponent0

	mFireworksLoopCue=SoundCue'FestiveGoatSounds.Fireworks_Loop_Cue'
	mFireworksCue=SoundCue'Goat_Sounds.Cue.Firework_Cue'
	mFireworksParticleTemplate=ParticleSystem'Goat_Effects.Effects.Effects_Fireworks_01'

	Begin Object class=CylinderComponent Name=CollisionCylinder
		CollideActors=true
		CollisionRadius=16.5
		CollisionHeight=40
		bAlwaysRenderIfSelected=true
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	Begin Object Class=ParticleSystemComponent Name=ParticleSystemComponent0
        Template=ParticleSystem'jetPack.Effects.JetThrust'
	End Object
	Components.Add(ParticleSystemComponent0)
	mFireParticle=ParticleSystemComponent0

	bCollideActors=true
	bProjTarget=true
	bStatic=false
	bNoDelete=false

	mBlockCamera=false
}