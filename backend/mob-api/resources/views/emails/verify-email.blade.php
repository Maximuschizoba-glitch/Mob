<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Verify your Mob email</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif; background: #f5f5f5; margin: 0; padding: 40px 20px; }
        .container { max-width: 480px; margin: 0 auto; background: #fff; border-radius: 12px; padding: 40px; }
        .logo { font-size: 28px; font-weight: 800; color: #111; margin-bottom: 24px; }
        h1 { font-size: 22px; color: #111; margin: 0 0 12px; }
        p { color: #555; line-height: 1.6; margin: 0 0 20px; }
        .token { font-size: 32px; font-weight: 700; letter-spacing: 8px; color: #111; background: #f0f0f0; border-radius: 8px; padding: 16px 24px; text-align: center; margin: 24px 0; }
        .footer { font-size: 12px; color: #aaa; margin-top: 32px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">Mob</div>
        <h1>Verify your email address</h1>
        <p>Hi {{ $userName }}, enter this code in the app to verify your email:</p>
        <div class="token">{{ $token }}</div>
        <p>This code expires in 24 hours. If you didn't create a Mob account, you can safely ignore this email.</p>
        <div class="footer">© {{ date('Y') }} Mob. All rights reserved.</div>
    </div>
</body>
</html>
