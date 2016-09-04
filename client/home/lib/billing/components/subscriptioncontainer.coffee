{ connect } = require 'react-redux'
{ createSelector } = require 'reselect'
getGroup = require 'app/util/getGroup'

subscription = require 'app/redux/modules/payment/subscription'

teamSize = -> getGroup()?.counts?.member ? 1

subscriptionTitle = createSelector(
  subscription.pricePerSeat
  subscription.isTrial
  subscription.trialDays
  teamSize
  (plan, isTrial, trialDays, size) ->
    if isTrial
      if trialDays is 7
      then "Koding Basic Trial (1 Week)"
      else "Koding Basic Trial (1 Month)"
    else
      noun = if size is 1 then 'Developer' else 'Developers'
      "$#{pricePerSeat} per Developer (#{size} #{noun})"
)


mapStateToProps = (state) ->
  return {
    subscriptionTitle: subscriptionTitle(state)
    pricePerSeat: subscription.pricePerSeat(state)
    teamSize: teamSize()
    endsAt: subscription.endsAt(state)
    isTrial: subscription.isTrial(state)
  }
