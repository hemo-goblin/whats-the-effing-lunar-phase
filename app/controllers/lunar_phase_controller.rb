class LunarPhaseController < ApplicationController
  helper LunarPhaseHelper
  def lunarPhase
    @exclamation = view_context.getRandomExclamation
    @lunarPhaseID = view_context.lunarPhaseTonight
    @lunarPhase = view_context.getLunarPhaseNameFromID(@lunarPhaseID)
    @iconName = view_context.getLunarIconNameFromID(@lunarPhaseID)
    @quote = view_context.getRandomQuote
  end
end


