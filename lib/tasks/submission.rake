require 'rake'
require 'paperclip'

namespace :pat do
	desc "Deletes all submissions."
	task :delete_all => [:environment] do
	  r = Room.find(2)
	  r.participants.each do |p|
	    p.submissions.each do |s|
	      s.destroy
	    end
	  end
	end

	desc "Lists all users."
	task :list_users => [:environment] do
	  r = Room.find(2)
	  #puts r.participants.map(&:attributes).to_yaml
	  r.participants.each do |p|
	  	puts p.id.to_s + ": " + p.user.first_name + " " + p.user.last_name + ", " + p.role
	  end
	end

	desc "Create fry submission."
	task :create_fry, [:arg1] => :environment do |t, args|
		room = Room.find(2)
		proto = Submission.find(2)
		p = Participant.find(args[:arg1].to_i)
		n = p.submissions.new 
		n.image = proto.image
		n.save
	end

	desc "Create leela submission."
	task :create_leela, [:arg1] => :environment do |t, args|
		room = Room.find(2)
		proto = Submission.find(3)
		p = Participant.find(args[:arg1].to_i)
		n = p.submissions.new 
		n.image = proto.image
		n.save
	end

	desc "Create chart submission."
	task :create_chart, [:arg1] => :environment do |t, args|
		room = Room.find(2)
		proto = Submission.find(34)
		p = Participant.find(args[:arg1].to_i)
		n = p.submissions.new 
		n.image = proto.image
		n.save
        end

	desc "Create multiple fry's."
	task :create_frys => :environment do |t, args|
		room = Room.find(2)
		proto = Submission.find(2)
		
		(170..175).each do |x|
			p = Participant.find(x)
			n = p.submissions.new 
			n.image = proto.image
			n.save
		end
	end

	desc "Create multiple leela's."
	task :create_leelas => :environment do |t, args|
		room = Room.find(2)
		proto = Submission.find(3)
		
		(170..175).each do |x|
			p = Participant.find(x)
			n = p.submissions.new 
			n.image = proto.image
			n.save
		end
	end	
end

