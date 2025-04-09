netstream.Hook("PlayQueuedSound", function(entity, sounds, delay, spacing, volume, pitch)
    entity = entity or LocalPlayer()

    ix.util.EmitQueuedSounds(entity, sounds, delay, spacing, volume, pitch)
end)