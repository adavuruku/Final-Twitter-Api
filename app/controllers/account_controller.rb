class AccountController < ApplicationController
    skip_before_action :verifyLogin, only: [:LoginUser, :CreateUser, :existingUserName, :ResetPassword]

    skip_before_action :verifyUserAdmin, only: [:LoginUser, :CreateUser, :existingUserName, :ResetPassword, 
    :CreateRetweet, :AddLikesToTweet, :ResetPassword, :loadTweets, :CreateTweet, :updatePassword, :updateProfile, :suggestPeopleToFollow,
    :viewProfile, :CreateFollowing, :Listfollowing, :unfollowing, :existingUserName, :listAllUsers, :AdminMakeAdmin]
    
    def CreateUser
        userName = params['userName']
        if VerifyValidUserName(userName)
            userName = userName[0] == "@" ? userName:"@".concat(userName)
            user =  UsersRecord.new
            user.username = userName
            user.userfullname = params['userFullName']
            user.useremail = params['userEmail']
            user.password = params['password']
            user.userid = rand(10000000...90000000)
            if user.save
                render json: user.as_json, status: :created
            else
                render json: {status:"error", code:422, message:"Unable To Create Account"}, status: :unprocessable_entity
            end
        else
            render json: {status:"error", code:422, message:"Invalid User Name"}, status: :unprocessable_entity
        end
    end

    def LoginUser
        userName = params['userName']
        password = params['password']
        userNameChange = userName[0] == "@" ? userName:"@".concat(userName)
        user = UsersRecord.where("(username = :userName or useremail = :userEmail) and active = :active", { userName: userNameChange, userEmail: userName, active: true }).limit(1)
        if user.count ==1 and user[0].authenticate(password)
            #generate web token
            webToken = GenerateLoginToken user[0].userid, user[0].id
            render json: {authentication:webToken, user:user}, status: :ok
        else
            render json: {status:"error", code:404, message:"User Not Exist"}, status: :not_found
        end
    end
    #################################################################################
    # people you are following                                                      #
    # followingId is the id of the user you are following                           #
    #you become a follower to the person your are following                         #
    # the person i wamt to follow must not login but must be a valid user           #
    #################################################################################

    def CreateFollowing
        myFollowId = params['followingId']
        myFollowRecord = UsersRecord.find_by("userid =:userId",{userId:myFollowId})
        if myFollowRecord
            if Following.where("userid= :userId and followingid= :followingId",{userId:getUserId[0]['userId'],followingId:myFollowId })
            .first_or_create(
                followingid:myFollowId,
                userid:getUserId[0]['userId'],
                users_record_id:getUserId[0]['rec_id']
            )
                following= Following.where("userid =:userId",{userId:getUserId[0]['userId']}).count
                render json: {following:following, message:"Following"}, status: :ok
            else
                # render json: {status:"error", code:200, message:"Failed to Follow"}, status: :unprocessable_entity
                render json: {message:"Already Following"}, status: :ok
            end
        else
            render json: {status:"error", code:422, message:"User Not Exist"}, status: :unprocessable_entity
        end
    end
    # people wey u dey follow  - 
    def Listfollowing
        following= Following.where("userid =:userId",{userId:getUserId[0]['userId']}).count
        render json: {following:following}, status: :ok
    end
    # people wey they follow you
    def Listfollowers
        follower= Following.where("followingid =:followingId",{followingId:getUserId[0]['userId']}).count
        render json: {follower:follower}, status: :ok
    end
    def unfollowing
        followOther = params['followingId']
        Following.delete_by(userid: getUserId[0]['userId'], followingid: followOther)
        following= Following.where("userid =:userId",{userId:getUserId[0]['userId']}).count
        render json: {following:following, message:"unfollowed"}, status: :ok
    end

    def suggestPeopleToFollow
        suggestFollow = [getUserId[0]['userId']]
        following= Following.where("userid =:userId",{userId:getUserId[0]['userId']})
        if following.count > 0
            following.each do |eachUser|
                suggestFollow.push(eachUser.followingid)
            end
        end
        usersSuggest = UsersRecord.where.not(userid: suggestFollow)
        usrsSuggestActive = usersSuggest.select{|eachPerson| eachPerson.active == true}
        render json: {usersSuggest:usrsSuggestActive}, status: :ok

        # Book.joins(:comments).where("comments.id = 2")
        # Book.joins(:comments).where(comments: { id: 2 })
        # Book.where(id: [1,2,3])
        # Book.where(category: "Programming").or(Book.where(category: "Ruby"))
        # Book.where.not(category: "Java")
        # Book.where("LENGTH(title) > ?", params[:min_length])
    end
    #################################################################################
    # Related Profile Actions                                                       #
    # - exisiting username                                                          #
    # - view single profile                                                         #
    # - all update on user profile                                                  #
    #################################################################################
    def existingUserName 
        userName = params['userName']
        userName = userName[0] == "@" ? userName:"@".concat(userName)
        user = UsersRecord.where("username like '%#{userName}%' ")
        allRecord = []
        user.each do |rec|
            eachrecord={}
            eachrecord[:username] = rec.username
            eachrecord[:userfullname] = rec.userfullname
            eachrecord[:userid] = rec.userid
            eachrecord[:dp] = (rec.dp.attached?) ? url_for(rec.dp) : ""
            allRecord.push(eachrecord)
        end
        render json: allRecord.as_json, status: :ok
    end
    def viewProfile
        user = UsersRecord.find_by_userid(getUserId[0]['userId'])
        showUser = user.as_json
        showUser[:dp] = (user.dp.attached?) ? url_for(user.dp) : ""
        showUser[:coverPhoto] = (user.coverPhoto.attached?) ? url_for(user.coverPhoto) : ""
        showUser[:followings] = user.followings.count
        showUser[:followers] = Following.where("followingId =:followingId",{followingId:getUserId[0]['userId']}).count
        showUser[:tweets] = Tweet.where("userid =:userId",{userId:getUserId[0]['userId']}).count
        allRetweet = Retweet.where("userid =:userId",{userId:getUserId[0]['userId']})

        if allRetweet.count > 0
            showUser[:retweets] = allRetweet[0].allretweet.count
        end

        # User.where("'Guest' = ANY(roles_array)")
        # Book.where("subjects @> ?", "{Finance,Business,Accounting}")
        render json: showUser.as_json, status: :ok
    end
    def updateProfile
        user = UsersRecord.find_by_userid(getUserId[0]['userId'])
        userPhone = !params['userPhone'].nil? ? ((params['userPhone'].present? and !params['userPhone'].empty?) ? params['userPhone'] : user.userphone) : user.userphone
        userBio = !params['userBio'].nil? ? ((params['userBio'].present? and !params['userBio'].empty?) ? params['userBio'] : user.userbio) : user.userbio
        userLocation = !params['userLocation'].nil? ? ((params['userLocation'].present? and !params['userLocation'].empty?) ? params['userLocation'] : user.userlocation): user.userlocation
        userWebsite = !params['userWebsite'].nil? ? ((params['userWebsite'].present? and !params['userWebsite'].empty?)  ? params['userWebsite'] : user.userwebsite) : user.userwebsite
        userEmail = !params['userEmail'].nil? ? ((params['userEmail'].present? and !params['userEmail'].empty?) ? params['userEmail'] : user.userEmail): user.useremail
        userFullName = !params['userFullName'].nil? ? ((params['userFullName'].present? and !params['userFullName'].empty?) ? params['userFullName'] : user.userfullname) : user.userfullname
        dob = !params['dob'].nil? ? ((params['dob'].present? and !params['dob'].empty?) ? params['dob'] : user.dob): user.dob
        
        user.update_attribute(:userphone, userPhone)
        user.update_attribute(:userbio, userBio)
        user.update_attribute(:userlocation, userLocation)
        user.update_attribute(:userwebsite, userWebsite)
        user.update_attribute(:useremail, userEmail)
        user.update_attribute(:userfullname, userFullName)
        user.update_attribute(:dob, dob)
        # upload display pics
        if params[:dp]
            user.dp.attach(params[:dp])
        end
        # display cover photo
        if params[:coverPhoto]
            user.coverPhoto.attach(params[:coverPhoto])
        end
        render json: {updated:"Updated"}, status: :ok
    end
    def updatePassword
        user = UsersRecord.find_by_userid(getUserId[0]['userId'])
        if user and user.authenticate(params['userOldPassword'])
            user.update_attribute(:password, params['userNewPassword'])
            render json: {updated:"Updated"}, status: :ok
        else
            render json: {status:"error", code:422, message:"Failed to Update"}, status: :unprocessable_entity
        end
    end
    def CreateTweet
        tweet = Tweet.new
        user = UsersRecord.find_by_userid(getUserId[0]['userId'])
        tweetBody = !params['tweetBody'].nil? ? ((params['tweetBody'].present? and !params['tweetBody'].empty?) ? params['tweetBody'] : "") : ""
        tweet.tweetinfo = tweetBody
        tweet.users_record_id = user.id
        tweet.userid = user.userid
        if params[:tweetAttachments]
            tweet.tweetAttachments.attach(params[:tweetAttachments])
        end
        
        if tweet.save
            # render json: Tweet.all.as_json, status: :ok
            render json: {message:"tweeted"}, status: :ok
        else
            render json: {status:"error", code:422, message:"Failed to Update"}, status: :unprocessable_entity
        end
    end
    def loadTweets
        current_page = params[:page] ? params[:page].to_i : 1
        recPerPage = 20
        recOffset = (current_page - 1) * recPerPage
        tweetAll = []
        following= Following.where("userid =:userId",{userId:getUserId[0]['userId']})

        sam = following.to_a.map{|p| p.followingid}.push(getUserId[0]['userId'])
        tweets = Tweet.where('userid IN (?)',sam).limit(recPerPage).offset(recOffset).order(id: :desc)
        tweets.each do |singleTweet|
            if singleTweet.active
                eachTweet ={}
                eachTweet[:tweet] = singleTweet
                tweetAttachs = []
                singleTweet.tweetAttachments.each do |tweetFile|
                    tweetAttachs.push(url_for(tweetFile))
                end
                eachTweet[:tweetAttachs] = tweetAttachs.as_json
                eachTweet[:userFullName] = singleTweet.users_record.userfullname
                eachTweet[:userName] = singleTweet.users_record.username
                eachTweet[:dp] = (singleTweet.users_record.dp.attached?) ? url_for(singleTweet.users_record.dp) : ""
                eachTweet[:likes] = singleTweet.likes.length
                tweetAll.push(eachTweet)
            end
        end

        # load all retweet for the user or retweets @> ARRAY[?]::varchar[]
        sam.each do |eachUser|
            retweetInfo = Retweet.where("userid = ?",eachUser)
            if retweetInfo.length > 0
                eachTweet ={}
                retweetInfo[0].allretweet.to_a.each do |eachTweetId|
                    tweets = Tweet.where('id =?', eachTweetId)
                    if tweets[0].active
                        eachTweet[:tweet] = tweets[0]
                        tweetAttachs = []
                        tweets[0].tweetAttachments.each do |tweetFile|
                            tweetAttachs.push(url_for(tweetFile))
                        end
                        eachTweet[:tweetAttachs] = tweetAttachs.as_json
                        eachTweet[:userFullName] = tweets[0].users_record.userfullname
                        eachTweet[:userName] = tweets[0].users_record.username
                        eachTweet[:dp] = (tweets[0].users_record.dp.attached?) ? url_for(tweets[0].users_record.dp) : ""
                        eachTweet[:likes] = tweets[0].likes.length
                        tweetAll.push(eachTweet)
                    end
                end
            end 
        end
        
        render json: tweetAll.shuffle.as_json, status: :ok
    end
    
    def ResetPassword
        userName = params['userName']
        userNameChange = userName[0] == "@" ? userName:"@".concat(userName)
        user = UsersRecord.where("username =:userName or useremail =:userEmail or userphone =:userPhone", { userName: userNameChange, userEmail: userName , userPhone: userName }).limit(1)
        if user.count ==1
        #     #process Maills
            resetToken = GenerateResetToken user[0].userid, user[0].useremail
            PasswordResetMailer.with(user:user[0].useremail, reset:resetToken).resetPasswordEmail.deliver_now
        #     # PasswordResetMailer.with({user:user[0].useremail, reset:resetToken}).resetPasswordEmail.deliver_now
            render json: {message:"Maill Sent"}, status: :ok
        else
            render json: {status:"error", code:404, message:"User Not Exist"}, status: :not_found
        end
    end
    def AddLikesToTweet
        user = Tweet.where("id = ?",params[:tweetId])
        if user.length > 0
            existingUsers = user[0].likes
            if !(existingUsers.include? getUserId[0]['userId'])
                existingUsers.push(getUserId[0]['userId'])
                user[0].update_attribute(:likes, existingUsers)
            end
            render json: {updated:"Liked", totalLike:existingUsers.length,totalRetweet:user[0].retweets.length, user:user[0].as_json}, status: :ok
        else
            render json: {error:"No Tweet"}, status: :ok
        end
    end
    
    def CreateRetweet
        existingUsers = []
        user = UsersRecord.find_by_userid(getUserId[0]['userId'])
        retweetInfo = Retweet.where("userid = ?",getUserId[0]['userId'])
        if retweetInfo.length > 0
            existingUsers = retweetInfo[0].allretweet.to_a
            if !(existingUsers.include? params[:tweetId].to_i)
                existingUsers.push(params[:tweetId])
                retweetInfo[0].update_attribute(:allretweet, existingUsers)
            end
            render json: {updated:"Retweet", totalRetweet:existingUsers.length, tweetsid:retweetInfo[0].as_json}, status: :ok
        else
            retweet = Retweet.new
            retweet.userid = getUserId[0]['userId']
            existingUsers.push(params[:tweetId])
            retweet.users_record_id = user.id
            retweet.allretweet = existingUsers
            retweet.save
            render json: {updated:"Retweet", totalRetweet:existingUsers.length, tweetsid:retweet.as_json}, status: :ok
        end
    end

    def listAllUsers
        user = UsersRecord.all
        render json: user.as_json, status: :ok
    end

    # //admin process begins
    def AdminDeleteUser
        userProcess = UsersRecord.find_by_userid(params['userId'])
        userProcess.update_attribute(:active, false)
        render json: {message:"Blocked"}, status: :ok
    end

    def AdminMakeAdmin
        userProcess = UsersRecord.find_by_userid(getUserId[0]['userId'])
        userProcess.update_attribute(:admin, true)
        render json: {message:"Blocked", userAdmin:userProcess.as_json}, status: :ok
    end

    def AdminDeleteTweet
        user = Tweet.where("id = ?",params[:tweetId])
        if user.length > 0
            user[0].update_attribute(:active, false)
            render json: {message:"Deleted"}, status: :ok
        else
            render json: {error:"No Tweet"}, status: :ok
        end
    end
    def AdminAllTweet
        # current_page = params[:page] ? params[:page].to_i : 1
        # recPerPage = 20
        # recOffset = (current_page - 1) * recPerPage
        # allTweets= Tweet.where('active = ?',true)
        # tweets = Tweet.where('active = ?',true).limit(recPerPage).offset(recOffset).order(id: :desc)
        # render json: {alltweets:tweets.as_json, page:current_page, totalTweets:allTweets.length}, status: :ok
        allTweets= Tweet.where('active = ?',true).order(id: :desc)
        # tweets = Tweet.where('active = ?',true).limit(recPerPage).offset(recOffset).order(id: :desc)
        render json: {alltweets:allTweets.as_json(:include => [:users_record]), totalTweets:allTweets.length}, status: :ok
    end
    def AdminCreateUser
        userName = params['userName']
        if VerifyValidUserName(userName)
            userName = userName[0] == "@" ? userName:"@".concat(userName)
            user =  UsersRecord.new
            user.username = userName
            user.userfullname = params['userFullName']
            user.useremail = params['userEmail']
            user.password = params['password']
            user.userid = rand(10000000...90000000)
            if user.save
                render json: user.as_json, status: :created
            else
                render json: {status:"error", code:422, message:"Unable To Create Account"}, status: :unprocessable_entity
            end
        else
            render json: {status:"error", code:422, message:"Invalid User Name"}, status: :unprocessable_entity
        end
    end

    def AdminEditUser
        user = UsersRecord.find_by_userid(params['userId'])
        if user
            userPhone = !params['userPhone'].nil? ? ((params['userPhone'].present? and !params['userPhone'].empty?) ? params['userPhone'] : user.userphone) : user.userphone
            userBio = !params['userBio'].nil? ? ((params['userBio'].present? and !params['userBio'].empty?) ? params['userBio'] : user.userbio) : user.userbio
            userLocation = !params['userLocation'].nil? ? ((params['userLocation'].present? and !params['userLocation'].empty?) ? params['userLocation'] : user.userlocation): user.userlocation
            userWebsite = !params['userWebsite'].nil? ? ((params['userWebsite'].present? and !params['userWebsite'].empty?)  ? params['userWebsite'] : user.userwebsite) : user.userwebsite
            userEmail = !params['userEmail'].nil? ? ((params['userEmail'].present? and !params['userEmail'].empty?) ? params['userEmail'] : user.userEmail): user.useremail
            userFullName = !params['userFullName'].nil? ? ((params['userFullName'].present? and !params['userFullName'].empty?) ? params['userFullName'] : user.userfullname) : user.userfullname
            dob = !params['dob'].nil? ? ((params['dob'].present? and !params['dob'].empty?) ? params['dob'] : user.dob): user.dob
            
            user.update_attribute(:userphone, userPhone)
            user.update_attribute(:userbio, userBio)
            user.update_attribute(:userlocation, userLocation)
            user.update_attribute(:userwebsite, userWebsite)
            user.update_attribute(:useremail, userEmail)
            user.update_attribute(:userfullname, userFullName)
            user.update_attribute(:dob, dob)
            # upload display pics
            if params[:dp]
                user.dp.attach(params[:dp])
            end
            # display cover photo
            if params[:coverPhoto]
                user.coverPhoto.attach(params[:coverPhoto])
            end
            render json: {updated:"Updated"}, status: :ok
        else
            render json: {status:"error", code:422, message:"Specify User Doesnot Exist"}, status: :unprocessable_entity
        end
    end

    # def UpdateResetPassword
    #     resetToken = params['resetToken']
    #     verifyPasswordResetToken(resetToken)
        
    #     userNameChange = userName[0] == "@" ? userName:"@".concat(userName)
    #     user = UsersRecord.where("username = :userName or useremail = :userEmail or userphone= :userPhone", 
    #     { userName: userNameChange, userEmail: userName , userPhone: userName }).limit(1)
    #     if user.count ==1
    #         #process Maills
    #         # resetToken = GenerateResetToken user[0].userid, user[0].useremail
    #         # PasswordResetMailer.with(user:user[0].useremail, reset:resetToken).resetPasswordEmail.deliver_now
    #         # PasswordResetMailer.with({user:user[0].useremail, reset:resetToken}).resetPasswordEmail.deliver_now
    #         render json: {message:"Maill Sent", email:user.useremail}, status: :ok
    #     else
    #         render json: {status:"error", code:404, message:"User Not Exist"}, status: :not_found
    #     end
    # end
    # private def post_user_params
    #     params.require(:UsersRecord).permit(:userEmail, :userName, :userFullName)
    # end
end
