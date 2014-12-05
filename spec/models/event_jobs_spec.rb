require 'spec_helper'

describe 'event jobs', :type => :model do
  before(:each) do
    @now = Time.now
    @user = FactoryGirl.find_or_create(:jill)
    @another_user = FactoryGirl.find_or_create(:archivist)
    @third_user = FactoryGirl.find_or_create(:curator)
    allow_any_instance_of(GenericFile).to receive(:terms_of_service).and_return('1')
    @gf = GenericFile.new(pid: 'test:123')
    @gf.apply_depositor_metadata(@user.login)
    @gf.title = 'Hamlet'
    @gf.save
  end
  after(:each) do
    @gf.delete
    @user.delete
    @another_user.delete
    @third_user.delete
    $redis.keys('events:*').each { |key| $redis.del key }
    $redis.keys('User:*').each { |key| $redis.del key }
    $redis.keys('GenericFile:*').each { |key| $redis.del key }
  end
  it "should log user edit profile events" do
    # UserEditProfile should log the event to the editor's dashboard and his/her followers' dashboards
    @another_user.follow(@user)
    count_user = @user.events.length
    count_another = @another_user.events.length
    Time.stub(now: 1)
    event = { action: 'User <a href="/users/jilluser">Jill Z. User</a> has edited his or her profile', timestamp: '1' }
    #UserEditProfileEventJob.perform(@user.login)
    UserEditProfileEventJob.new(@user.user_key).run
    expect(@user.events.length).to eq(count_user + 1)
    expect(@user.events.first).to eq(event)
    expect(@another_user.events.length).to eq(count_another + 1)
    expect(@another_user.events.first).to eq(event)
  end
  it "should log user follow events" do
    # UserFollow should log the event to the follower's dashboard, the followee's dashboard, and followers' dashboards
    @third_user.follow(@user)
    expect(@user.events.length).to eq(0)
    expect(@another_user.events.length).to eq(0)
    expect(@third_user.events.length).to eq(0)
    Time.stub(now: 1)
    event = { action: 'User <a href="/users/jilluser">Jill Z. User</a> is now following <a href="/users/archivist1">archivist1</a>', timestamp: '1' }
    #UserFollowEventJob.perform(@user.login, @another_user.login)
    UserFollowEventJob.new(@user.user_key, @another_user.user_key).run
    expect(@user.events.length).to eq(1)
    expect(@user.events.first).to eq(event)
    expect(@another_user.events.length).to eq(1)
    expect(@another_user.events.first).to eq(event)
    expect(@third_user.events.length).to eq(1)
    expect(@third_user.events.first).to eq(event)
  end
  it "should log user unfollow events" do
    # UserUnfollow should log the event to the unfollower's dashboard, the unfollowee's dashboard, and followers' dashboards
    @third_user.follow(@user)
    @user.follow(@another_user)
    expect(@user.events.length).to eq(0)
    expect(@another_user.events.length).to eq(0)
    expect(@third_user.events.length).to eq(0)
    Time.stub(now: 1)
    event = { action: 'User <a href="/users/jilluser">Jill Z. User</a> has unfollowed <a href="/users/archivist1">archivist1</a>', timestamp: '1' }
    #UserUnfollowEventJob.perform(@user.login, @another_user.login)
    UserUnfollowEventJob.new(@user.user_key, @another_user.user_key).run
    expect(@user.events.length).to eq(1)
    expect(@user.events.first).to eq(event)
    expect(@another_user.events.length).to eq(1)
    expect(@another_user.events.first).to eq(event)
    expect(@third_user.events.length).to eq(1)
    expect(@third_user.events.first).to eq(event)
  end
  it "should log content deposit events" do
    # ContentDeposit should log the event to the depositor's profile, followers' dashboards, and the GF
    @another_user.follow(@user)
    @third_user.follow(@user)
    allow_any_instance_of(User).to receive(:can?).and_return(true)
    expect(@user.profile_events.length).to eq(0)
    expect(@another_user.events.length).to eq(0)
    expect(@third_user.events.length).to eq(0)
    expect(@gf.events.length).to eq(0)
    Time.stub(now: 1)
    event = {action: 'User <a href="/users/jilluser">Jill Z. User</a> has deposited <a href="/files/123">Hamlet</a>', timestamp: '1' }
    #ContentDepositEventJob.perform('test:123', @user.login)
    ContentDepositEventJob.new('test:123', @user.user_key).run
    expect(@user.profile_events.length).to eq(1)
    expect(@user.profile_events.first).to eq(event)
    expect(@another_user.events.length).to eq(1)
    expect(@another_user.events.first).to eq(event)
    expect(@third_user.events.length).to eq(1)
    expect(@third_user.events.first).to eq(event)
    expect(@gf.events.length).to eq(1)
    expect(@gf.events.first).to eq(event)
  end
  it "should log content update events" do
    # ContentUpdate should log the event to the depositor's profile, followers' dashboards, and the GF
    @another_user.follow(@user)
    @third_user.follow(@user)
    allow_any_instance_of(User).to receive(:can?).and_return(true)
    expect(@user.profile_events.length).to eq(0)
    expect(@another_user.events.length).to eq(0)
    expect(@third_user.events.length).to eq(0)
    expect(@gf.events.length).to eq(0)
    Time.stub(now: 1)
    event = {action: 'User <a href="/users/jilluser">Jill Z. User</a> has updated <a href="/files/123">Hamlet</a>', timestamp: '1' }
    #ContentUpdateEventJob.perform('test:123', @user.login)
    ContentUpdateEventJob.new('test:123', @user.user_key).run
    expect(@user.profile_events.length).to eq(1)
    expect(@user.profile_events.first).to eq(event)
    expect(@another_user.events.length).to eq(1)
    expect(@another_user.events.first).to eq(event)
    expect(@third_user.events.length).to eq(1)
    expect(@third_user.events.first).to eq(event)
    expect(@gf.events.length).to eq(1)
    expect(@gf.events.first).to eq(event)
  end
  it "should log content new version events" do
    # ContentNewVersion should log the event to the depositor's profile, followers' dashboards, and the GF
    @another_user.follow(@user)
    @third_user.follow(@user)
    allow_any_instance_of(User).to receive(:can?).and_return(true)
    expect(@user.profile_events.length).to eq(0)
    expect(@another_user.events.length).to eq(0)
    expect(@third_user.events.length).to eq(0)
    expect(@gf.events.length).to eq(0)
    Time.stub(now: 1)
    event = {action: 'User <a href="/users/jilluser">Jill Z. User</a> has added a new version of <a href="/files/123">Hamlet</a>', timestamp: '1' }
    #ContentNewVersionEventJob.perform('test:123', @user.login)
    ContentNewVersionEventJob.new('test:123', @user.user_key).run
    expect(@user.profile_events.length).to eq(1)
    expect(@user.profile_events.first).to eq(event)
    expect(@another_user.events.length).to eq(1)
    expect(@another_user.events.first).to eq(event)
    expect(@third_user.events.length).to eq(1)
    expect(@third_user.events.first).to eq(event)
    expect(@gf.events.length).to eq(1)
    expect(@gf.events.first).to eq(event)
  end
  it "should log content restored version events" do
    # ContentRestoredVersion should log the event to the depositor's profile, followers' dashboards, and the GF
    @another_user.follow(@user)
    @third_user.follow(@user)
    allow_any_instance_of(User).to receive(:can?).and_return(true)
    expect(@user.profile_events.length).to eq(0)
    expect(@another_user.events.length).to eq(0)
    expect(@third_user.events.length).to eq(0)
    expect(@gf.events.length).to eq(0)
    Time.stub(now: 1)
    event = {action: 'User <a href="/users/jilluser">Jill Z. User</a> has restored a version \'content.0\' of <a href="/files/123">Hamlet</a>', timestamp: '1' }
    #ContentRestoredVersionEventJob.perform('test:123', @user.login, 'content.0')
    ContentRestoredVersionEventJob.new('test:123', @user.user_key, 'content.0').run
    expect(@user.profile_events.length).to eq(1)
    expect(@user.profile_events.first).to eq(event)
    expect(@another_user.events.length).to eq(1)
    expect(@another_user.events.first).to eq(event)
    expect(@third_user.events.length).to eq(1)
    expect(@third_user.events.first).to eq(event)
    expect(@gf.events.length).to eq(1)
    expect(@gf.events.first).to eq(event)
  end
  it "should log content delete events" do
    # ContentDelete should log the event to the depositor's profile and followers' dashboards
    @another_user.follow(@user)
    @third_user.follow(@user)
    expect(@user.profile_events.length).to eq(0)
    expect(@another_user.events.length).to eq(0)
    expect(@third_user.events.length).to eq(0)
    Time.stub(now: 1)
    event = {action: 'User <a href="/users/jilluser">Jill Z. User</a> has deleted file \'123\'', timestamp: '1' }
    #ContentDeleteEventJob.perform('test:123', @user.login)
    ContentDeleteEventJob.new('test:123', @user.user_key).run
    expect(@user.profile_events.length).to eq(1)
    expect(@user.profile_events.first).to eq(event)
    expect(@another_user.events.length).to eq(1)
    expect(@another_user.events.first).to eq(event)
    expect(@third_user.events.length).to eq(1)
    expect(@third_user.events.first).to eq(event)
  end
  it "should not log content-related jobs to followers who lack access" do
    # No Content-related eventjobs should log an event to a follower who does not have access to the GF
    @another_user.follow(@user)
    @third_user.follow(@user)
    expect(@user.profile_events.length).to eq(0)
    expect(@another_user.events.length).to eq(0)
    expect(@third_user.events.length).to eq(0)
    expect(@gf.events.length).to eq(0)
    @now = Time.now
    Time.stub(now: @now)
    event = {action: 'User <a href="/users/jilluser">Jill Z. User</a> has updated <a href="/files/123">Hamlet</a>', timestamp: @now.to_i.to_s }
    #ContentUpdateEventJob.perform('test:123', @user.login)
    ContentUpdateEventJob.new('test:123', @user.user_key).run
    expect(@user.profile_events.length).to eq(1)
    expect(@user.profile_events.first).to eq(event)
    expect(@another_user.events.length).to eq(0)
    expect(@another_user.events.first).to be_nil
    expect(@third_user.events.length).to eq(0)
    expect(@third_user.events.first).to be_nil
    expect(@gf.events.length).to eq(1)
    expect(@gf.events.first).to eq(event)
  end
end

