module Paginatable
  extend ActiveSupport::Concern

  DEFAULT_LIMIT = 20
  MAX_LIMIT = 100

  private

    def paginate(scope)
      page = params.fetch(:page, 1).to_i
      limit = params.fetch(:limit, DEFAULT_LIMIT).to_i

      page = 1 if page < 1
      limit = limit.clamp(1, MAX_LIMIT)

      total_count = scope.count
      total_pages = (total_count.to_f / limit).ceil
      offset = (page - 1) * limit

      paginated_scope = scope.limit(limit).offset(offset)

      next_page = page < total_pages ? page + 1 : nil
      prev_page = page > 1 ? page - 1 : nil

      meta = { page:, limit:, total_count:, total_pages:, next_page:, prev_page: }

      [ paginated_scope, meta ]
    end
end
