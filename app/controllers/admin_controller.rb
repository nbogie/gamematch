class AdminController < ApplicationController
  def tables
  end
  
  def prepLinkStats
    total = Player.count
    unlinked = Player.where(bgg_username: nil).count
    linked = total - unlinked
    pct = 100.0 * linked / total
    {total: total, unlinked: unlinked, linked: linked, pct: pct}
  end
  
  def prepCollectionStats
    { geeks: Player.active_and_have_collection_at_least(5).load.size }
  end
  
  def prepVisitedStats
    weeks = {}
    1.upto(4) do |i|
      weeks[i] = Player.visitedInLastNWeeks(i).count
    end
    { total: Player.count, weeks: weeks }
  end
  
  def stats
    @link_stats = prepLinkStats
    @visited_stats = prepVisitedStats
    @collection_stats = prepCollectionStats
  end  

end
