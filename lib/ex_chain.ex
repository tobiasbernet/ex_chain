defmodule ExChain do
  @moduledoc """
  Documentation for ExChain.

  https://medium.com/@mycoralhealth/code-your-own-blockchain-in-less-than-200-lines-of-go-e296282bcffc

  - `Index` is the position of the data record in the blockchain
  - `Timestamp` is automatically determined and is the time the data is written
  - `BPM` or beats per minute, is your pulse rate
  - `Hash` is a SHA256 identifier representing this data record
  - `PrevHash` is the SHA256 identifier of the previous record in the chain
  """

  defstruct [:index, :timestamp, :bpm, :hash, :prev_hash]

  defp add_hash(hash, %__MODULE__{} = block) do
    %{block | hash: hash}
  end

  @doc """
  So how does hashing fit into blocks and the blockchain? 
  We use hashes to identify and keep the blocks in the right order. 
  By ensuring the PrevHash in each Block is identical to Hash in the previous Block we know the proper order of the blocks that make up the chain.

  This calculate_hash function concatenates Index, Timestamp, BPM, PrevHash of the Block we provide as an argument and returns the SHA256 hash as a string. 
  Now we can generate a new Block with all the elements we need with a new generateBlock function. 
  We’ll need to supply it the previous block so we can get its hash and our pulse rate in BPM. 
  Don’t worry about the BPM int argument that’s passed in. We’ll address that later.
  """
  def calculate_hash(
        %__MODULE__{
          index: index,
          timestamp: timestamp,
          bpm: bpm,
          prev_hash: prev_hash
        } = _block
      ) do
    record =
      "#{Integer.to_string(index)}#{Integer.to_string(timestamp)}#{Integer.to_string(bpm)}#{
        prev_hash
      }"

    :sha256
    |> :crypto.hash(record)
    |> Base.encode16()
    |> String.downcase()
  end

  def is_block_valid?(
        %__MODULE__{
          index: prev_index,
          hash: old_hash
        } = _old_block,
        %__MODULE__{
          index: index,
          prev_hash: prev_hash,
          hash: hash
        } = new_block
      ) do
    cond do
      prev_index + 1 != index -> false
      old_hash != prev_hash -> false
      calculate_hash(new_block) != hash -> false
      true -> true
    end
  end

  def generate_block() do
    generate_block(%__MODULE__{index: 0, hash: ""}, 1)
  end

  def generate_block(
        %__MODULE__{
          index: prev_index,
          hash: prev_hash
        } = _old_block,
        bpm
      ) do
    new_block = %__MODULE__{
      index: prev_index + 1,
      timestamp: :os.system_time(:micro_seconds),
      bpm: bpm,
      prev_hash: prev_hash
    }

    new_block
    |> calculate_hash()
    |> add_hash(new_block)
  end
end
