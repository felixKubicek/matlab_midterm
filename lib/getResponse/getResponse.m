function [rt, response] = getResponse(responseSetCodes,t0,tDEADLINE)
% FUNCTION [rt, response] = getResponse(responseSetCodes, t0, tDEADLINE)
% collect response using standard keyboard, return reaction time and response key
% inputs:
%	responseSetCodes:	set of numeric codes corresponding to response keys, obtained in caller by calling KbName(responseSet), with responseSet a cell array of response Keys, e.g., responseSet = {'LeftArrow', 'y', 'n'}; responseSetCodes = KbName(responseSet)
%	t0: onset of stimulus presentation
%	tDEADLINE: maximum response time before trial is counted as invalid

%Flushkeyboard warte solange, bis Stille ist auf dem keyboard
keyIsDown = true;
while keyIsDown
    keyIsDown = KbCheck(-1);
end

%jetzt warten wir auf die Antwort
done = false;
while ~done
    [keyIsDown, secs, keyCode] = KbCheck(-1);
    if keyIsDown && sum(keyCode)==1 %nur eine Taste betaetigt
        if any(keyCode(responseSetCodes)) %ist denn eine Taste aus dem responseSet gedrueckt worden?
            rt = secs-t0; %REaktionszeit ist die Uhrzeit des Tastendrucks - Uhrzeit der REizpraesentation
            response = KbName(keyCode);
            done = true;
        end
    elseif secs - t0 > tDEADLINE %ist die deadline erreicht?
        rt = NaN;
        response = 'DEADLINE';
        done = true;
    end
end
