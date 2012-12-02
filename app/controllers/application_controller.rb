class ApplicationController < ActionController::Base
  protect_from_forgery

  def index
    
  end
  
  def create
    session = GoogleDrive.login(ENV['gmail'], ENV['gmailp'])
    spreadsheet = session.create_spreadsheet("ACCOUNTability: "+params[:project_name])
    ws_generated = spreadsheet.worksheets[0]
    ws_generated.list.keys = ["timestamp", "phone number", "item", "description", "amount"]
    ws_generated.list.push({"timestamp" => Time.now, 
                       "phone number" => "+14692086681", 
                       "item" => "pencil", 
                       "description" => "lost the previous", 
                       "amount" => "2.50"})
                       
    ws_generated.save
    
    ws_number_to_key = session.spreadsheet_by_key("0AsNrDUUNJ35MdFJkOUZZaTNzeTdPQTRWNmV2ZzJydFE").worksheets[0]
    ws_number_to_key.list.push({"Phone Number" => params[:phone_number], 
                       "Spreadsheet Key" => spreadsheet.key})
    ws_number_to_key.save
    spreadsheet.acl.push({:scope_type => "user", :scope => params[:email], :role => "owner"})
    flash[:notice] = "Your new spreadsheet is available <a href='#{spreadsheet.human_url}'> here.</a>"
    redirect_to root_url
  end
  def add
    session = GoogleDrive.login(ENV['gmail'], ENV['gmailp'])
    ws_number_to_key = session.spreadsheet_by_key("0AsNrDUUNJ35MdFJkOUZZaTNzeTdPQTRWNmV2ZzJydFE").worksheets[0]
    hash_row = ws_number_to_key.list.to_hash_array.find{|list_row| list_row["Phone Number"] == params[:From]}
        
    ws_account = session.spreadsheet_by_key(hash_row["Spreadsheet Key"]).worksheets[0]
    values = params[:Body].split(",").map{|value| value.strip}
        
    ws_account.list.push({"timestamp" => Time.now, 
                           "phone number" => params[:From], 
                           "item" => values[0], 
                           "description" => values[2], 
                           "amount" => values[1]})
    ws_account.save
        
    
    
  end
  
  #def addNumber
  #  session = GoogleDrive.login(ENV['gmail'], ENV['gmailp'])
  #  ws_number_to_key = session.spreadsheet_by_key("0AsNrDUUNJ35MdFJkOUZZaTNzeTdPQTRWNmV2ZzJydFE").worksheets[0]
  #  hash_row = ws_number_to_key.list.to_hash_array.find{|list_row| list_row["Phone Number"] == params[:old_number]}
  #  ws_number_to_key.list.push({"Phone Number" => params[:new_number], 
  #                     "Spreadsheet Key" => hash_row["Spreadsheet Key"]})
  #  ws_number_to_key.save
  #  session.spreadsheet_by_key(hash_row["Spreadsheet Key"]).acl.push({:scope_type => "user", :scope => params[:email], :role => "viewer"})
    
  #end
  
  
end
