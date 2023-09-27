using { /Fortnite.com/Devices }
using {/Fortnite.com/Characters}
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
Attach := class(creative_device):

    @editable var Monster : creative_prop = creative_prop{}
    @editable var MonsterMutator : mutator_zone_device = mutator_zone_device{}

    @editable       DamageVolumeProps : []creative_prop = array{}
    @editable       DamageVolumeOffset : float = 350.0

    OnBegin<override>()<suspends>:void=
        MonsterMutator.AgentEntersEvent.Subscribe(OnPlayerSpotted)
        Players := GetPlayspace().GetPlayers()
            if (Player := Players[0], Agent := agent[Player]):

    OnPlayerSpotted(Agent : agent):void=
            Players := GetPlayspace().GetPlayers()
            if (Player := Players[0]):
                spawn:
                    FollowPlayer(Monster, Player)
                spawn{ DamageTrail(Player) }
                
    DamageTrail(Player : player)<suspends> : void =
        if (FortCharacter := Player.GetFortCharacter[]):
            var LastPosition : transform = FortCharacter.GetTransform()
            var CurrentDamageVolumeIndex : int = 0

            loop:
                Sleep(0.0)

                if:
                    Distance(LastPosition.Translation, FortCharacter.GetTransform().Translation) > DamageVolumeOffset / 2.0
                    DamageVolumeProp := DamageVolumeProps[CurrentDamageVolumeIndex]
                then:
                    if (DamageVolumeProp.TeleportTo[LastPosition]) {}
                    set LastPosition = FortCharacter.GetTransform()
                    set CurrentDamageVolumeIndex += 1
                    if (CurrentDamageVolumeIndex = DamageVolumeProps.Length):
                        set CurrentDamageVolumeIndex = 0

    FollowPlayer(Enemy : creative_prop, Player : player)<suspends>:void=
        var PreviousTime : float = GetSimulationElapsedTime()
            MoveSpeed := 25
            loop:
                Sleep(0.0)
                CurrentTime := GetSimulationElapsedTime()
                DeltaTime := CurrentTime - PreviousTime
                set PreviousTime = CurrentTime
                if (PlayerCharacter := Player.GetFortCharacter[], Enemy.IsValid[]):
    
                    PropLocation := Enemy.GetTransform().Translation
                    PlayerLocation := PlayerCharacter.GetTransform().Translation
    
                    if (LookDirection := (PlayerLocation - PropLocation).MakeUnitVector[]):
    
                        Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X)) - 90.0
                        Pitch := 0.0 #RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
                        Roll := 0.0
    
                        NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
    
                        # Movement
                        LerpLocation := Lerp(PropLocation, PlayerLocation, DeltaTime * MoveSpeed)
                        FinalLocation := vector3{X := LerpLocation.X, Y := LerpLocation.Y, Z := LerpLocation.Z}
    
                        if:
                            Enemy.TeleportTo[FinalLocation, NewRotation]
