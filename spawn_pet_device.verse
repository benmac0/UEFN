
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
spawn_pet_device := class(creative_device):
   

    @editable var Monster : creative_prop = creative_prop{}
    @editable var MonsterMutator : mutator_zone_device = mutator_zone_device{}
    @editable
    MaxDistanceToPlayer<private> : float = 1000.0
    
    OnBegin<override>()<suspends>:void=
        MonsterMutator.AgentEntersEvent.Subscribe(OnPlayerSpotted)
        Players := GetPlayspace().GetPlayers()
            if (Player := Players[0], Agent := agent[Player]):


    OnPlayerSpotted(Agent : agent):void=
            Players := GetPlayspace().GetPlayers()
            if (Player := Players[0]):
                if:
                    not IsMoving?
                then:
                    set IsMoving = true
                    spawn:
                        FollowPlayer(Monster, Player)
                
    FollowPlayer(Enemy : creative_prop, Player : player)<suspends>:void=
        var PreviousTime : float = GetSimulationElapsedTime()
            defer:
                set IsMoving = false
            MoveSpeed := 20
            loop:
                Sleep(0.0)

                if (PlayerCharacter := Player.GetFortCharacter[], Enemy.IsValid[]):
                    
                    PlayerTran := PlayerCharacter.GetTransform()
                    
                    PlayerLocation := PlayerCharacter.GetTransform().Translation
                    Sleep(0.5)
                    PropLocation := Enemy.GetTransform().Translation
                    
                    DistanceFromPlayer := Distance(PlayerLocation, PropLocation)
                    
			            if:
				            DistanceFromPlayer > MaxDistanceToPlayer
			            then:
                            Enemy.MoveTo(PlayerTran.Translation, Enemy.GetTransform().Rotation, 0.0)


                            if (LookDirection := (PlayerLocation - PropLocation).MakeUnitVector[]):
    
                                Yaw := RadiansToDegrees(ArcTan(LookDirection.Y, LookDirection.X)) - 90.0
                                Pitch := 0.0 #RadiansToDegrees(ArcTan(LookDirection.Z, Sqrt((LookDirection.X * LookDirection.X) + (LookDirection.Y * LookDirection.Y))))
                                Roll := 0.0

                                NewRotation := MakeRotationFromYawPitchRollDegrees(Yaw, Pitch, Roll)
                                Enemy.MoveTo(Enemy.GetTransform().Translation, NewRotation, 0.0)
			

