# Prepares Hash Params
class PreparerParams
  attr_reader :opts
  def initialize(opts)
    @opts = opts
  end

  # Prepare params
  # @return [Hash] Prepared Hash params
  def prepare
    strip
    symbolize_keys
  end

  private

  def strip
    opts.map { |key, value| [key, value.strip!] }.to_h
  end

  def symbolize_keys
    opts.map { |key, value| [key.to_sym, value] }.to_h
  end
end
