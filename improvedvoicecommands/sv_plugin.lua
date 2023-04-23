-- I apologise for the amount of loops in all of this lol, also for the lack of comments, i tend to change my code a lot.
local PLUGIN = PLUGIN
PLUGIN.TempStored = PLUGIN.TempStored or {}

-- if no separator then just seperate at spaces
local function GetVoiceCommands(text, class, separator)
    local strings = string.Explode(separator or " ", text)
    local finaltable = {}
    local usedkeys = {}

    for k, v in ipairs(strings) do
        if usedkeys[k] then continue end

        v = string.Trim(v)

        local info = Schema.voices.Get(class, v)

        if !info then
            if !separator then
                local combiner
                local temp = {}

                for i = k, #strings do
                    combiner = combiner and combiner .. " " .. strings[i] or strings[i]

                    info = Schema.voices.Get(class, combiner)

                    temp[i] = true

                    if info then
                        usedkeys = temp
                        break
                    end
                end
            end
        end
        table.insert(finaltable, !info and {text = v} or table.Copy(info))
    end
    return finaltable
end

local function ExperimentalFormatting(stringtabl)
    local carry
    -- carry like in mathematical equations :)
    -- the point of the carry is to move question marks or exclamation marks to the end of the text
    for k, v in ipairs(stringtabl) do
        local before, after = stringtabl[k - 1] and k - 1, stringtabl[k + 1] and k + 1

        -- if we are not a voice command, check if we have someone before us, cuz if we do and they are a voice command than only they can have the carry symbol set
        if !v.sound then
            if before and carry and stringtabl[before].sound and string.sub(stringtabl[before].text, #stringtabl[before].text, #stringtabl[before].text) != "," then
                local text = stringtabl[before].text
                stringtabl[before].text = string.SetChar(text, #text, carry)
                carry = nil
            end
            -- we only want voice commands to be corrected
            continue
        end

        -- if there is a string before us adjust the casing of our first letter according to the before's symbol
        if before then
            local sub = string.sub(stringtabl[before].text, #stringtabl[before].text, #stringtabl[before].text)
            local case = string.lower(string.sub(v.text, 1, 1))

            if sub == "!" or sub == "." or sub == "?" then
                case = string.upper(string.sub(v.text, 1, 1))
            end

            v.text = string.SetChar(v.text, 1, case)
        end

        -- if there is a string after us adjust our symbol to their casing. if they are a vc always adjust to comma, if they are not, check if the message starts with a lower casing letter, indicating a conntinuation of the sentence
        if after then
            local firstletterafter = string.sub(stringtabl[after].text, 1, 1)
            local endsub = string.sub(v.text, #v.text, #v.text)

            if stringtabl[after].sound or string.match(firstletterafter, "%l") then
                if endsub == "!" or endsub == "." or endsub == "?" then
                    v.text = string.SetChar(v.text, #v.text, ",")
                    if stringtabl[after].sound and endsub != "." then
                        carry = carry == nil and endsub or carry
                    end
                end
            end
        end

        -- we are a vc so we can also set the carry to us
        if carry then
            if !after then
                v.text = string.SetChar(v.text, #v.text, carry) 
                carry = nil
                continue
            end
        end
    end
    return stringtabl
end

function Schema:PlayerMessageSend(speaker, chatType, text, anonymous, receivers, rawText)
    local separator = ix.config.Get("separatorVC", nil) != "" and ix.config.Get("separatorVC", nil) or nil

	if chatType == "ic" or chatType == "w" or chatType == "y" or chatType == "dispatch" or (ix.config.Get("radioVCAllow", true) and chatType == "radio") then
		local class = self.voices.GetClass(speaker)

		for k, v in pairs(class) do
            local texts = GetVoiceCommands(rawText, v, separator)
            local isGlobal = false
            local completetext
            local sounds = {}
            if ix.config.Get("experimentalModeVC", false) == true then
                texts = ExperimentalFormatting(texts)
            end
            for k2, v2 in ipairs(texts) do
                if v2.sound then
                    if v2.global then
                        isGlobal = true
                    end
                    table.insert(sounds, v2.sound)
                end

                local volume = isGlobal and 0 or 80
                if chatType == "w" then
                    volume = 60
                elseif chatType == "y" then
                    volume = 150
                end

                completetext = completetext and completetext .. " " .. v2.text or v2.text

                if k2 == #texts then
                    if table.IsEmpty(sounds) then break end

                    if speaker:IsCombine() and !isGlobal then
                        speaker.bTypingBeep = nil
                        table.insert(sounds, "NPC_MetroPolice.Radio.Off")
                    end

                    local _ = !isGlobal and ix.util.EmitQueuedSounds(speaker, sounds, nil, nil, volume) or netstream.Start(nil, "PlayQueuedSound", nil, sounds, nil, nil, volume)

                    if chatType == "radio" then
                        volume = ix.config.Get("radioVCVolume", 60)
                        if ix.config.Get("radioVCClientOnly", false) == true then
                            netstream.Start(receivers, "PlayQueuedSound", nil, sounds, nil, nil, volume)
                        else
                            for k3, v3 in pairs(receivers) do
                                if v3 == speaker then continue end
                                ix.util.EmitQueuedSounds(v3, sounds, nil, nil, volume)
                            end
                        end
                    end

                    text = completetext

                    goto exit
                end
            end
        end

        ::exit::

        PLUGIN.TempStored[CurTime()] = text

        if speaker:IsCombine() then
            if chatType != "radio" then
                return string.format("<:: %s ::>", text)
            end
        end
        return text
    end

    -- this isnt optimal but it works
    if chatType == "radio_eavesdrop" then
        if PLUGIN.TempStored[CurTime()] then
            text = PLUGIN.TempStored[CurTime()]
            PLUGIN.TempStored[CurTime()] = nil
        end
    end
    return text
end
