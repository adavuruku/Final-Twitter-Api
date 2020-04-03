class PasswordResetMailer < ApplicationMailer
    default from: 'aabdulraheemsherif@gmail.com'
    def resetPasswordEmail(useremail, resetToken )
        @url  = 'https://cryptic-ridge-07009.herokuapp.com/login?reset='.concat(resetToken.to_s)
        mail(to: useremail, subject: 'Your Twitter Password Reset Link')
    end
end
