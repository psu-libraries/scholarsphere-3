module Selectors

  module Dashboard

    def file_actions_toggle(id)
      within "#document_#{id}" do
        find ".dropdown-toggle"
      end
    end
  end

  module NewTransfers

    def new_owner_dropdown
      find '#s2id_proxy_deposit_request_transfer_to'
    end

    def new_owner_search_field
      within '#select2-drop' do
        find '.select2-input'
      end
    end

    def new_owner_search_result
      within '#select2-drop' do
        find '.select2-result-selectable'
      end
    end

    def submit_button
      within '#new_transfer' do
        find 'input[type=submit]'
      end
    end
  end
end

