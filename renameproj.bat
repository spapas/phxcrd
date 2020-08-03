IF [%CURRENT_OTP%] == [] exit /b 1
IF [%CURRENT_NAME%] == [] exit /b 1

ag --nocolor -0 -l %CURRENT_OTP% | xargs -0 sed -i '' -e "s/%CURRENT_OTP%/%NEW_OTP%/g"

ag --nocolor -0 -l %CURRENT_NAME% | xargs -0 sed -i '' -e "s/%CURRENT_NAME%/%NEW_NAME%/g"

move lib\%CURRENT_OTP% lib\%NEW_OTP%
move lib\%CURRENT_OTP%.ex lib\%NEW_OTP%.ex
move lib\%CURRENT_OTP%_web lib\%NEW_OTP%_web
move lib\%CURRENT_OTP%_web.ex lib\%NEW_OTP%_web.ex
move test\%CURRENT_OTP% test\%NEW_OTP%
move test\%CURRENT_OTP%_web test\%NEW_OTP%_web