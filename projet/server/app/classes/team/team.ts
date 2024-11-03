type Member = string;

export class Team {
    members: Array<Member> = [];

    constructor(member: Member) {
        this.members.push(member)
    }

    addMember(member: Member) {
        this.members.push(member);
    }

    // If we remove the last member return true else false
    removeMember(userId: string) {
        const initialLength = this.members.length;
        if (this.members.length > 0) this.members.forEach((member: Member, index: number) => {
           if (member === userId) this.members.splice(index, 1);
        });
        return (this.members.length === 0 && initialLength !== 0)
    }
}