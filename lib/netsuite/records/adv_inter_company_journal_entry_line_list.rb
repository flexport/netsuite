module NetSuite
  module Records
    class AdvInterCompanyJournalEntryLineList < Support::Sublist
      include Namespaces::TranGeneral

      sublist :line, AdvInterCompanyJournalEntryLine

      alias :lines :line
    end
  end
end
