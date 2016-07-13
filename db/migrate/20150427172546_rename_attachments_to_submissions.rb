class RenameAttachmentsToSubmissions < ActiveRecord::Migration
  def change
    rename_table :attachments, :submissions
  end
end
