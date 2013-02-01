# Simple monitoring of Exim mail queue size
#
class Exim < Scout::Plugin
  OPTIONS=<<-EOS
  exim_command_path:
    notes: "provide the full path to exim if necessary (possibly with sudo)"
    default: exim
  EOS

  def build_report
    exim_command=option(:exim_command_path) || "exim"
    exim_command+= " -bpc"
    output=`#{exim_command}`.strip
    if output == ""
      error("#{exim_command} returned no output")
    else
      report(:queue_size=>output.to_i)
    end
  end
end
