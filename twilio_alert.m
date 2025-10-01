function sendTwilioSMS()
    % Twilio account details (replace with your real credentials)
    accountSID = 'AC7c7d4322824c0acb94503ee995be1ca0';
    authToken  = 'd5f61b74ea98eeb2d82f93878f3c6151';
    fromNum    = '+16067220049';       % Your Twilio number
    toNum      = '+917483081028';      % Destination number

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
