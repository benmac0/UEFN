using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }


#===========================================================
# Creates a prop and moves it alongside player
prop_follow_device := class(creative_device):

    @editable
    var PropAsset : creative_prop_asset = DefaultCreativePropAsset

    OnBegin<override>()<suspends>:void=
        Sleep(2.0)

        # Assume zeroeth player
        if (Target := PlayerAsPositional[0]):
            Print("Creating prop...")

            # Three meters in front of player
            TargetXform  := Target.GetTransform()
            PropSpawnPos := TargetXform.Translation + TargetXform.Rotation.GetLocalForward() * 300.0
            PropInfo     := SpawnProp(PropAsset, PropSpawnPos, IdentityRotation())

            if (Prop := PropInfo(0)?):
                Print("Following prop is active!")
                # Follow 2 meters to the right
                Right := vector3{X:=0.0, Y:=1.0, Z:=0.0}
                Prop.FollowPositional(Target, Right * 200.0)
            else:
                Print("Invalid spawn info for prop!")

    #===========================================================
    # Gets the specified player index as a positional object
    PlayerAsPositional(PlayerIdx : int)<transacts><decides>:positional =
        GetPlayspace().GetPlayers()[PlayerIdx].GetFortCharacter[]

    #===========================================================
    # Have this prop follow the specified positional target at the specified offset
    # [Note that this is an "extension function" that allows calling it as if it were a member method.]
    (Prop : creative_prop).FollowPositional(Target : positional, Offset : vector3)<suspends>:void =
        loop:
            Print("Moving...")
            Prop.MoveToPositional(Target, Offset)
            Print("Arrived. Waiting...")
            # Wait a bit until moving again - could just be 0.0 or passed in
            Sleep(1.0)

    #===========================================================
    # Move to specified offset of positional target adjusting over time as needed
    # *** Partly corrects glitch in MoveTo() that occasionally resets position
    (Prop : creative_prop).MoveToPositional(Target : positional, Offset : vector3)<suspends>:void =
        TargetRotation := IdentityRotation()  # [Could specify a target rotation or make relative to Target]
        
        loop:
            TargetXform := Target.GetTransform()
            TargetPos := TargetXform.Translation
            var PropXform : transform = transform{}

            Arrived := race:
                block:
                    MovePos := TargetPos + TargetXform.Rotation.RotateVector(Offset)
                    # The farther apart the longer the time to get there [could pass in adjustment]
                    TimeToMove := Distance(TargetPos, Prop.GetTransform().Translation) * 0.005
                    # If MoveTo() is canceled before arrival (such as with the nesting `race` it seems
                    # to reset to the prop's original position
                    Prop.MoveTo(MovePos, TargetRotation, TimeToMove)
                    # The MoveTo() arrival criteria is quite picky so it may never complete
                    true
                block:
                    # Update move to location occasionally [could pass in value]
                    Sleep(0.5)
                    # Note current prop xform before MoveTo is canceled by race
                    set PropXform = Prop.GetTransform()
                    false

            if:
                not Arrived?
                # Teleport to position prior to adjustment - fixes occasional glitching of MoveTo()
                Prop.TeleportTo[PropXform]
            then:
                # Wait 2 update frames before calling MoveTo again - just 1 doesn't seem to always be enough
                Sleep(0.0)
                Sleep(0.0)
            else:
                # Arrived
                break


    #===========================================================
    # Move to specified offset of positional target adjusting over time as needed
    # - uses code that would be expected if MoveTo() did not have a glitch
    (Prop : creative_prop).MoveToPositionalExpected(Target : positional, Offset : vector3)<suspends>:void =
        TargetRotation := IdentityRotation()  # [Could specify a target rotation or make relative to Target]
        
        loop:
            TargetXform := Target.GetTransform()
            TargetPos := TargetXform.Translation

            Arrived := race:
                block:
                    MovePos := TargetPos + TargetXform.Rotation.RotateVector(Offset)
                    # The farther apart the longer the time to get there [could pass in adjustment]
                    TimeToMove := Distance(TargetPos, Prop.GetTransform().Translation) * 0.005
                    Prop.MoveTo(MovePos, TargetRotation, TimeToMove)
                    true   # Arrived
                block:
                    # Update move to location occasionally [could pass in value]
                    Sleep(0.5)
                    false  # Not arrived

            if (Arrived?):
                break
