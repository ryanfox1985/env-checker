require 'spec_helper'

describe EnvChecker do
  it 'create a new missing keys error' do
    expect(EnvChecker::MissingKeysError.new('Error!')).not_to be nil
  end
end
