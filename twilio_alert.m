function sendTwilioSMS()
    % Twilio account details (replace with your real credentials)
    accountSID = 'accountSID';
    authToken  = 'authToken';
    fromNum    = ' fromNum ';       % Your Twilio number
    toNum      = ' toNum ';      % Destination number

    message    = 'Hazardous RF level detected';

    url = sprintf('https://api.twilio.com/2010-04-01/Accounts/%s/Messages.json', accountSID);

    % Convert data to a string format that Twilio accepts (form-encoded)
    data = [
        "To=" + urlencode(toNum) + ...
        "&From=" + urlencode(fromNum) + ...
        "&Body=" + urlencode(message)
    ];

    % Set web options for form-encoded data and basic auth
    options = weboptions( ...
        'Username', accountSID, ...
        'Password', authToken, ...
        'MediaType', 'application/x-www-form-urlencoded' ...
    );

    % Send SMS
    try
        response = webwrite(url, data, options);
        disp(' SMS sent successfully.');
    catch ME
        fprintf('SMS failed:\n%s\n', ME.message);
    end
end
