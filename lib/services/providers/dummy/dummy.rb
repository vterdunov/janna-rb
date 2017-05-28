Dummy = Struct.new(:perform_async, :new) do
  def perform_async(*args); end

  def new(*args); end
end
